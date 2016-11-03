#!/bin/bash
export RAILS_ENV=production
cd /usr/src/app
case ${DOCKER_STATE} in
create)
    echo "running create"
    bundle exec rails db:setup
    ;;
migrate)
    echo "running migrate"
    bundle exec rails db:migrate
    ;;
reset)
    echo "running reset - db:drop and db:setup"
    bundle exec rails db:reset
    ;;
esac
bundle exec puma -C config/puma.rb
