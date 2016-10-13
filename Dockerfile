FROM ministryofjustice/ruby:2.3.1-webapp-onbuild

ENV PUMA_PORT 3000

RUN touch /etc/inittab

RUN apt-get update && apt-get upgrade -y

EXPOSE $PUMA_PORT

RUN gem install bundler

RUN bundle exec rake assets:precompile RAILS_ENV=production \
  AAQ_EMAIL_DOMAIN=required_but_does_not_matter_for_assets \
  SECRET_KEY_BASE=required_but_does_not_matter_for_assets

RUN bundle exec foreman export upstart /etc/init -a correspondence\
  -u root -l /var/correspondence/log

ENTRYPOINT ["./run.sh"]
