#!/bin/bash

bundle exec rackup sidekiq-admin.ru -p 3000  -o 0.0.0.0 &
bundle exec sidekiq --daemon -l /var/log/sidekiq.log

tail -f /usr/src/app/log/production.log
