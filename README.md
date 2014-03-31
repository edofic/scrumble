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

### Frontend

- install node.js - https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
- install Ruby and compass gem (rvm and Ruby 2.1.1 preferred)
- install grunt-cli and bower
- install npm and bower dependencies

**Docker install example**

```
apt-get install software-properties-common curl vim git libpng12-0

add-apt-repository ppa:chris-lea/node.js
apt-get update
apt-get install python g++ make nodejs

\curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.1.1
rvm use 2.1.1

gem install compass

npm install -g grunt-cli bower

git clone https://github.com/edofic/scrumble.git

cd scrumble/scrumbleweb

npm install
bower --allow-root install
```

**Setup development environment**

    cd scrumble/scrumbleweb
    source /etc/profile.d/rvm.sh
    rvm use 2.1.1

**Run development server**

    grunt serve

**Run tests**

    grunt test
