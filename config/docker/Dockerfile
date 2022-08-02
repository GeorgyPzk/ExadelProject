#FROM ruby:2.7.5-bullseye

FROM exadeltaskapps.azurecr.io/base_image:latest

ARG ENV development
ENV CURRENT_ENV=$ENV
ENV NODE_ENV $CURRENT_ENV
ENV RAILS_ENV $CURRENT_ENV

ENV DISABLE_DATABASE_ENVIRONMENT_CHECK 1

COPY ./src /opt/app

RUN cp config/database.${CURRENT_ENV}.yml config/database.yml && cp config/config.${CURRENT_ENV}.yml config/config.yml



# RUN bundle  exec rake db:create

# RUN bundle exec rake db:structure:load


RUN bundle exec rake ts:index

RUN bundle exec rake ts:start

RUN bundle exec rake assets:precompile

#RUN bundle exec rake jobs:work

#RUN bundle exec rails server -e production




CMD ["script/startup.sh"]
ENTRYPOINT ["script/entrypoint.sh"]

#
# Assets
#

# Fix ownership of directories that need to be writable
RUN mkdir -p \
          app/assets/webpack \
          public/assets \
          public/webpack \
    && chown -R app:app \
       app/assets/javascripts \
       app/assets/webpack \
       client/app/ \
       public/assets \
       public/webpack

# If assets.tar.gz file exists in project root
# assets will be extracted from there.
# Otherwise, assets will be compiled with `rake assets:precompile`.
# Useful for caching assets between builds.
RUN script/prepare-assets.sh


# Example
