
library(shiny)
library(stringdist)

# LOGIN (disabled): on Shinylive / GitHub Pages the app runs in the browser, so a login
# cannot protect anything. Uncomment these lines to use it again on a Shiny server.
# library(shinymanager)
# library(scrypt)

# credentials <- data.frame(user = c("user"),
#                           password = c(scrypt::hashPassword("user")),
#                           is_hashed_password = TRUE,
#                           stringsAsFactors = FALSE)

#------------------------------------------------------------------------------------------
# Pure-R port of fuzzywuzzy's 'fuzz.WRatio()' (python 'fuzzywuzzy' + 'python-Levenshtein')
# so that the application runs without Python (e.g. in the browser using Shinylive / webR).
# The matching blocks of 'partial_ratio' follow the edit-operations backtrace of rapidfuzz,
# which python-Levenshtein (>= 0.20) uses.
#------------------------------------------------------------------------------------------

fw_process <- function(s) {
  s <- gsub("[\u0080-ÿ]", "", s, perl = TRUE)                # force_ascii (as in fuzzywuzzy for python 3)
  s <- gsub("(*UCP)\\W", " ", s, perl = TRUE)                      # non letters / numbers to whitespace
  trimws(tolower(s))
}

# python-Levenshtein ratio: (len(a) + len(b) - indel distance) / (len(a) + len(b))
fw_lev_ratio <- function(a, b) {
  lensum <- nchar(a) + nchar(b)
  if (lensum == 0) return(1)
  (lensum - stringdist::stringdist(a, b, method = "lcs")) / lensum
}

fw_ratio <- function(a, b) {
  if (identical(a, b)) return(100)
  if (!nzchar(a) || !nzchar(b)) return(0)
  round(100 * fw_lev_ratio(a, b))
}

# matching blocks (0-based start in 'a', start in 'b', length) as python-Levenshtein computes them
fw_matching_blocks <- function(s1, s2) {
  a <- strsplit(s1, "")[[1]]; b <- strsplit(s2, "")[[1]]
  n1 <- length(a); n2 <- length(b)
  pre <- 0
  while (pre < n1 && pre < n2 && a[pre + 1] == b[pre + 1]) pre <- pre + 1
  suf <- 0
  while (suf < n1 - pre && suf < n2 - pre && a[n1 - suf] == b[n2 - suf]) suf <- suf + 1
  A <- a[pre + seq_len(n1 - pre - suf)]; B <- b[pre + seq_len(n2 - pre - suf)]
  la <- length(A) + 1; lb <- length(B) + 1
  M <- matrix(0L, la, lb); M[1, ] <- 0:(lb - 1); M[, 1] <- 0:(la - 1)
  if (la > 1 && lb > 1) {
    for (i in 2:la) for (j in 2:lb) {
      M[i, j] <- min(M[i - 1, j - 1] + (A[i - 1] != B[j - 1]), M[i, j - 1] + 1L, M[i - 1, j] + 1L)
    }
  }
  # backtrace as in rapidfuzz (used by python-Levenshtein >= 0.20); D[c, r] = distance of A[1:c], B[1:r]
  keep_a <- seq_len(pre) - 1; keep_b <- seq_len(pre) - 1
  col <- la - 1; row <- lb - 1
  while (row > 0 && col > 0) {
    if (M[col + 1, row + 1] - M[col, row + 1] == 1) { col <- col - 1; next }                    # deletion
    row <- row - 1
    if (row > 0 && M[col + 1, row + 1] - M[col, row + 1] == -1) next                           # insertion
    col <- col - 1
    if (A[col + 1] == B[row + 1]) { keep_a <- c(keep_a, col + pre); keep_b <- c(keep_b, row + pre) }   # match
  }
  keep_a <- c(keep_a, n1 - suf + seq_len(suf) - 1); keep_b <- c(keep_b, n2 - suf + seq_len(suf) - 1)
  ord <- order(keep_a); keep_a <- keep_a[ord]; keep_b <- keep_b[ord]
  blocks <- data.frame(a = integer(0), b = integer(0), len = integer(0))
  k <- 1
  while (k <= length(keep_a)) {
    run <- 1
    while (k + run <= length(keep_a) && keep_a[k + run] == keep_a[k] + run && keep_b[k + run] == keep_b[k] + run) run <- run + 1
    blocks <- rbind(blocks, data.frame(a = keep_a[k], b = keep_b[k], len = run))
    k <- k + run
  }
  rbind(blocks, data.frame(a = n1, b = n2, len = 0))
}

fw_partial_ratio <- function(a, b) {
  if (identical(a, b)) return(100)
  if (!nzchar(a) || !nzchar(b)) return(0)
  if (nchar(a) <= nchar(b)) { shorter <- a; longer <- b } else { shorter <- b; longer <- a }
  blocks <- fw_matching_blocks(shorter, longer)
  scores <- numeric(0)
  for (k in seq_len(nrow(blocks))) {
    long_start <- max(blocks$b[k] - blocks$a[k], 0)
    r <- fw_lev_ratio(shorter, substr(longer, long_start + 1, long_start + nchar(shorter)))
    if (r > 0.995) return(100)
    scores <- c(scores, r)
  }
  round(100 * max(scores))
}

fw_tokens <- function(s) {
  tok <- strsplit(s, "\\s+")[[1]]
  tok[nzchar(tok)]
}

fw_join_sorted <- function(tok) paste(sort(tok, method = "radix"), collapse = " ")

fw_token_sort_ratio <- function(a, b, partial = FALSE) {
  f <- if (partial) fw_partial_ratio else fw_ratio
  f(fw_join_sorted(fw_tokens(a)), fw_join_sorted(fw_tokens(b)))
}

fw_token_set_ratio <- function(a, b, partial = FALSE) {
  t1 <- unique(fw_tokens(a)); t2 <- unique(fw_tokens(b))
  sect <- fw_join_sorted(intersect(t1, t2))
  c12 <- trimws(paste(sect, fw_join_sorted(setdiff(t1, t2))))
  c21 <- trimws(paste(sect, fw_join_sorted(setdiff(t2, t1))))
  f <- if (partial) fw_partial_ratio else fw_ratio
  max(f(sect, c12), f(sect, c21), f(c12, c21))
}

WRatio <- function(s1, s2) {
  p1 <- fw_process(s1); p2 <- fw_process(s2)
  if (!nzchar(p1) || !nzchar(p2)) return(0)
  unbase_scale <- 0.95
  partial_scale <- 0.90
  base <- fw_ratio(p1, p2)
  len_ratio <- max(nchar(p1), nchar(p2)) / min(nchar(p1), nchar(p2))
  if (len_ratio > 8) partial_scale <- 0.6
  if (len_ratio >= 1.5) {
    res <- max(base,
               fw_partial_ratio(p1, p2) * partial_scale,
               fw_token_sort_ratio(p1, p2, partial = TRUE) * unbase_scale * partial_scale,
               fw_token_set_ratio(p1, p2, partial = TRUE) * unbase_scale * partial_scale)
  } else {
    res <- max(base,
               fw_token_sort_ratio(p1, p2) * unbase_scale,
               fw_token_set_ratio(p1, p2) * unbase_scale)
  }
  round(res)
}
