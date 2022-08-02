FROM ruby:2.7.5-bullseye


# Expose port
EXPOSE 3000


# Sphinx
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list.d/sphinx.list


# Update cache and upgrade packages
RUN apt-get update && apt-get dist-upgrade -y


# Disable IPv6 usage of GnuPG
RUN mkdir ~/.gnupg \
  && chmod 600 ~/.gnupg \
  && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Install Node.JS
# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key"; \
  done


ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 10.15.3
ENV NPM_CONFIG_LOGLEVEL error

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs


# Add helper for decrypting secure environment variables
RUN curl -sfSL \
  -o /usr/sbin/secure-environment \
  "https://github.com/convox/secure-environment/releases/download/v0.0.1/secure-environment" \
  && echo "4e4c1ed98f1ff4518c8448814c74d6d05ba873879e16817cd6a02ee5013334ea */usr/sbin/secure-environment" \
  | sha256sum -c - \
  && chmod 755 /usr/sbin/secure-environment


# Install MySQL client, sendmail, sphinxsearch and nginx
COPY ./src/script/setup-mysql-apt-repo.sh /root/

RUN apt-get install -y nginx \
  && /root/setup-mysql-apt-repo.sh \
  && apt-get install -y libmysqlclient-dev mysql-client unixodbc libpq5 \
  && apt-get -y install sphinxsearch sendmail


# Install Bundler
ENV BUNDLE_BIN=
RUN gem install bundler

# Add user app
RUN useradd -m -s /bin/bash app \
	&& mkdir /opt/app /opt/app/client /opt/app/log /opt/app/tmp && chown -R app:app /opt/app

# Change working directory
WORKDIR /opt/app



# Set environment (temporary)
ENV CURRENT_ENV production

# Copy gemfile and install dependencies
COPY ./src/Gemfile ./src/Gemfile.lock /opt/app/

# Install dependencies with or without development packages depending on environment
COPY ./src/install_bundle.sh /opt/app/

# Install bundles/packages
RUN chmod +x ./install_bundle.sh && ./install_bundle.sh

# Install Node.JS packages
COPY ./src/package.json /opt/app/
COPY ./src/client/package.json ./src/client/package-lock.json /opt/app/client/

# Install Yarn
RUN npm install --global yarn

# Convert package-lock.json to Yarn's yarn.lock
RUN cd client && yarn import

# Install Node.JS packages
RUN yarn install
