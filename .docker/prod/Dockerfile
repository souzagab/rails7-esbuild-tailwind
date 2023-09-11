
# syntax = docker/dockerfile:1

ARG RUBY_IMAGE=${RUBY_IMAGE:-ruby:3.2-alpine3.17}
ARG NODE_IMAGE=${NODE_IMAGE:-node:20-alpine3.16}

FROM $RUBY_IMAGE as base

ARG APP_USER_ID=1000
ARG APP_GROUP_ID=1000

ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_PATH=/rails

ARG PG_VERSION=15

ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH="vendor/bundle" \
    BUNDLE_DEPLOYMENT="1" \
    APP_PATH=$APP_PATH

RUN addgroup -g $APP_GROUP_ID -S $APP_GROUP \
  && adduser -s /sbin/nologin -u $APP_USER_ID -G $APP_GROUP $APP_USER -S \
  && gem update --system --no-document \
  && gem install -N bundler

COPY .docker/common/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

FROM $NODE_IMAGE AS node
FROM base as build

COPY --link --from=node /usr/lib /usr/lib
COPY --link --from=node /usr/local/share /usr/local/share
COPY --link --from=node /usr/local/lib /usr/local/lib
COPY --link --from=node /usr/local/include /usr/local/include
COPY --link --from=node /usr/local/bin /usr/local/bin

RUN apk add --update --no-cache tzdata bash less \
  && apk add --no-cache --virtual .base build-base libxml2-dev libxslt-dev  \
  && apk add --no-cache postgresql${PG_VERSION}-dev postgresql${PG_VERSION}-client \
  && npm install -g yarn@1 -f

WORKDIR $APP_PATH

COPY --link Gemfile Gemfile.lock ./

RUN bundle install \
  && bundle exec bootsnap precompile --gemfile \
  && rm -rf ~/.bundle/ $BUNDLE_PATH/ruby/*/cache $BUNDLE_PATH/ruby/*/bundler/gems/*/.git

COPY --link package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY --link . .

RUN bundle exec bootsnap precompile app/ lib/

RUN SECRET_KEY_BASE=DUMMY bundle exec rails assets:precompile

FROM base as app

RUN apk add --update --no-cache libpq-dev tzdata

WORKDIR $APP_PATH

COPY --link \
     --from=build \
     --chown=$APP_USER_ID:$APP_GROUP_ID \
     $APP_PATH $APP_PATH

USER $APP_USER

ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true"

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
