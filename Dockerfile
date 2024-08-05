FROM ruby:3.2.3-alpine as builder

# build dependencies:
RUN apk add --no-cache \
    ruby-dev \
    build-base \
    postgresql-dev \
    curl-dev \
    tzdata \
    yarn

WORKDIR /app

COPY Gemfile* .ruby-version package.json yarn.lock ./

RUN bundle config deployment true && \
    bundle config without development test && \
    bundle install --jobs 4 --retry 3 && \
    yarn install --frozen-lockfile

# Copy all files to /app
COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# Copy fonts and images (without digest) along with the digested ones,
# as there are some hardcoded references in the `govuk-frontend` files
# that will not be able to use the rails digest mechanism.
RUN cp -r node_modules/govuk-frontend/dist/govuk/assets/. public/assets/

# tidy up installation
RUN rm -rf log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache

# Build runtime image
FROM ruby:3.2.3-alpine

# The application runs from /app
WORKDIR /app

# libpq: required to run postgres, tzdata: required to set timezone, nodejs: JS runtime
RUN apk add --no-cache \
    curl \
    nodejs \
    tzdata \
    postgresql-client

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Create log and tmp
RUN mkdir -p log tmp
RUN chown -R appuser:appgroup db log tmp

USER 1000

# expect/add ping environment variables
ARG APP_GIT_COMMIT
ARG APP_BUILD_DATE
ARG APP_BUILD_TAG
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
