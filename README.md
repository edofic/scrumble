# Scrumble

## Setting up development environment

### Backend
Usage of *cabal sandbox* is recommended thus requiring `cabal >= 1.18`

    cabal sandbox init
    cabal install --enable-tests --only-dependencies --jobs
    cabal install yesod-bin --jobs

For running in development mode do

    yesod devel

For tests

    yesod test

