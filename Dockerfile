FROM ruby:3.2.3-alpine as builder

# build dependencies:
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    curl-dev \
    tzdata \
    yarn

# RUN apk add --no-cache libc-dev gcc libxml2-dev libxslt-dev make postgresql-dev build-base curl-dev git nodejs zip postgresql-client runit yarn

WORKDIR /app

COPY Gemfile* .ruby-version ./

RUN gem install bundler -v 2.4.19
RUN bundle config deployment true && \
    bundle config without development test && \
    bundle install --jobs 4 --retry 3

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copy all files to /app
COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# tidy up installation
RUN rm -rf log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete


# Build runtime image
FROM ruby:3.2.3-alpine

# The application runs from /app
WORKDIR /app

# libpq: required to run postgres, tzdata: required to set timezone, nodejs: JS runtime
RUN apk add --no-cache libpq tzdata nodejs curl-dev

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
