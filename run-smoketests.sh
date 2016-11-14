#!/bin/bash

# Even though we are running in a production environment, the smoke
# test has gem dependencies we prefer to keep in the test environment
# (e.g. mechanize and mail gems).
export RAILS_ENV=test

# By default we only install production gems in our Docker containers,
# and Bundler conspires to help & frustrate us by remembering that.
bundle install --with=test

# For some reason the she-bang line in smoketest.rb runs:
#   /usr/bin/env "rails runner"
# instead of:
#   /usr/bin/env "rails" "runner"
# bizarro. Version of env? bash?
rails runner ./smoketest.rb $TEST_SITE_URL

exit $?
