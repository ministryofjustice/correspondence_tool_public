FROM ruby:3.2.2-alpine

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

# Note: .ruby-gemdeps libc-dev gcc libxml2-dev libxslt-dev make postgresql-dev build-base curl-dev with bundle install issues.
RUN apk add --no-cache --virtual .ruby-gemdeps libc-dev gcc libxml2-dev libxslt-dev make postgresql-dev build-base curl-dev git nodejs zip postgresql-client runit

# set WORKDIR
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

RUN apk -U upgrade

COPY Gemfile* ./
RUN gem install bundler -v 2.4.19
RUN bundle config deployment true && \
    bundle config without development test && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN RAILS_ENV=production bundle exec rake assets:clean assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# Copy fonts and images (without digest) along with the digested ones,
# as there are some hardcoded references in the `govuk-frontend` files
# that will not be able to use the rails digest mechanism.
RUN cp -r node_modules/govuk-frontend/dist/govuk/assets/. public/assets/

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup ./*
RUN chmod +x /usr/src/app/config/docker/*
USER 1000

ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

# expect/add ping environment variables
ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ENV APP_VERSION=${VERSION_NUMBER}
ENV APP_GIT_COMMIT=${COMMIT_ID}
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}
