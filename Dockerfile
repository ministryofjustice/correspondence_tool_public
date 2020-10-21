FROM ruby:2.5.8

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

# set WORKDIR
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

COPY Gemfile* ./
RUN gem install bundler -v 1.16.2
RUN bundle config --global frozen 1 && \
    bundle config --path=vendor/bundle && \
    bundle install --without development test

RUN apt-get update && apt-get install -y apt-transport-https && \
	less \
	nodejs \
	runit \
	postgresql-client-9.5 \
    rm -rf /var/lib/apt/lists/*

COPY . .

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL repo to sources
RUN . /etc/os-release ; release="${VERSION#* (}" ; release="${release%)}" ; \
    echo "deb https://apt.postgresql.org/pub/repos/apt/ $release-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN RAILS_ENV=production bundle exec rake assets:clean assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db
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

ENTRYPOINT ["./run.sh"]