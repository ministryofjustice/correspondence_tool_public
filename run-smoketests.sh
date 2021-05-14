#!/bin/sh

# By default we only install production gems in our Docker containers,
# and Bundler conspires to help & frustrate us by remembering that.
bundle install --with=test

rake smoke

exit $?
