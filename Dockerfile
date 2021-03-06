FROM ruby:2.3.1
ARG UKPDS_DATA_URI_PREFIX
ARG UKPDS_DATA_ENDPOINT

ENV APP_USER parliament

# create user to run app in user space
RUN set -x \
        && groupadd -g 5000 $APP_USER \
        && adduser --disabled-password --uid 5000 --gid 5000 --gecos '' $APP_USER

ENV RAILS_ROOT /opt/memberserviceapi
ENV UKPDS_DATA_URI_PREFIX $UKPDS_DATA_URI_PREFIX
ENV UKPDS_DATA_ENDPOINT $UKPDS_DATA_ENDPOINT

RUN mkdir -p $RAILS_ROOT

# cache the gems
COPY Gemfile $RAILS_ROOT/Gemfile
COPY Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN cd $RAILS_ROOT && gem install bundler
RUN cd $RAILS_ROOT && env NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install \
  	&& chown -R $APP_USER:$APP_USER $GEM_HOME

# add project
COPY . $RAILS_ROOT
RUN chown -R $APP_USER:$APP_USER $RAILS_ROOT

USER $USER
WORKDIR $RAILS_ROOT

ARG GIT_SHA=unknown
ARG GIT_TAG=unknown
LABEL git-sha=$GIT_SHA git-tag=$GIT_TAG

# EXPOSE 3000

CMD ["passenger", "start"]
