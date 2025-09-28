
# REFERENCE: https://github.com/ranikay/shiny-reticulate-app
# This file configures the virtualenv and Python paths differently depending on
# the environment the app is running in (local vs remote server).

# Minimal .Rprofile - let reticulate auto-detect Python
VIRTUALENV_NAME = 'example_env_name'

if (Sys.info()[['user']] != 'shiny') {
  # Only set options for non-shinyapps.io environments
  if (Sys.info()[['user']] == 'rstudio-connect') {
    # Running on remote server
    Sys.setenv(PYTHON_PATH = '/opt/python/3.7.7/bin/python3')
    Sys.setenv(VIRTUALENV_NAME = paste0(VIRTUALENV_NAME, '/'))
    Sys.setenv(RETICULATE_PYTHON = paste0(VIRTUALENV_NAME, '/bin/python'))
  } else {
    # Running locally
    options(shiny.port = 7450)
    Sys.setenv(VIRTUALENV_NAME = VIRTUALENV_NAME)
  }
}
