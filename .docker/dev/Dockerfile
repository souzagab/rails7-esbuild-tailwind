# Development Dockerfile
ARG RUBY_IMAGE=${RUBY_IMAGE:-ruby:3.2-alpine3.17}
ARG NODE_IMAGE=${NODE_IMAGE:-node:20-alpine3.16}

FROM $NODE_IMAGE AS node

FROM $RUBY_IMAGE as assets

ARG APP_USER_ID=1000
ARG APP_USER_GROUP=1000

ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_PATH=/rails-app

ARG PG_VERSION=15

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN apk add --update --no-cache tzdata bash less \
  && apk add --no-cache --virtual .base build-base libxml2-dev libxslt-dev  \
  && apk add --no-cache postgresql${PG_VERSION}-dev postgresql${PG_VERSION}-client \
  && npm install -g yarn@1 -f \
  && addgroup -g $APP_USER_GROUP -S $APP_GROUP \
  && adduser -s /sbin/nologin -u $APP_USER_ID -G $APP_GROUP $APP_USER -S

ENV APP_PATH $APP_PATH

RUN gem update --system \
  && mkdir -p $APP_PATH/vendor/bundle \
  && chown $APP_USER:$APP_GROUP -R $APP_PATH

VOLUME $APP_PATH/vendor

USER $APP_USER

WORKDIR $APP_PATH

COPY --chown=$APP_USER_ID:$APP_USER_GROUP Gemfile* $APP_PATH/

RUN bundle config path "vendor/bundle" \
  && bundle install --retry 3

COPY --chown=$APP_USER:$APP_GROUP package.json *yarn* ./

RUN yarn install

COPY --chown=$APP_USER:$APP_GROUP . $APP_PATH/

CMD ["bash"]

FROM $RUBY_IMAGE as app

ARG APP_USER_ID=1000
ARG APP_USER_GROUP=1000

ARG APP_USER=app
ARG APP_GROUP=app
ARG APP_PATH=/rails-app

RUN apk add --update --no-cache libpq-dev tzdata bash less \
  && addgroup -g $APP_USER_GROUP -S $APP_GROUP \
  && adduser -s /sbin/nologin -u $APP_USER_ID -G $APP_GROUP $APP_USER -S

ENV APP_PATH $APP_PATH

COPY .docker/common/entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

VOLUME $APP_PATH/vendor

USER $APP_USER

WORKDIR $APP_PATH

COPY --from=assets --chown=$APP_USER:$APP_GROUP /usr/local/bundle/config /usr/local/bundle/config
COPY --from=assets --chown=$APP_USER:$APP_GROUP $APP_PATH $APP_PATH

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
