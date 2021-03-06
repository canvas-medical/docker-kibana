FROM quay.io/aptible/ubuntu:14.04

# Install NGiNX.
RUN apt-get update && \
    apt-get install -y software-properties-common \
    python-software-properties && \
    add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get -y install curl ucspi-tcp apache2-utils nginx ruby

ENV KIBANA_5_VERSION 5.0.1
ENV KIBANA_5_SHA1SUM 66f058017219d23ef5534545f5c6ad1dca4bb1fd

# ENV KIBANA_5_VERSION 5.2.2
# ENV KIBANA_5_SHA1SUM a9c9a74a0684756bced3d0009a09a4006e5b258e

# Kibana 5
RUN curl -fsSLO "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" && \
    echo "${KIBANA_5_SHA1SUM}  kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" | sha1sum -c - && \
    tar xzf "kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" -C /opt && \
    mv "/opt/kibana-${KIBANA_5_VERSION}-linux-x86_64" "/opt/kibana-${KIBANA_5_VERSION}" && \
    rm "kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz"

# Overwrite default nginx config with our config.
RUN rm /etc/nginx/sites-enabled/*
ADD templates/sites-enabled /

ADD templates/opt/kibana-5.x/ /opt/kibana-${KIBANA_5_VERSION}/config

RUN cd "/opt/kibana-${KIBANA_5_VERSION}/" && ./bin/kibana-plugin install https://github.com/canvas-medical/kibana-html-formatter/releases/download/v5.0.1/html-formatter-5.0.1.zip
# RUN cd "/opt/kibana-${KIBANA_5_VERSION}/" && ./bin/kibana-plugin install https://github.com/canvas-medical/kibana-html-formatter/releases/download/v5.2.2/html-formatter-5.2.2.zip

RUN rm "/opt/kibana-${KIBANA_5_VERSION}/config/kibana.yml"

# Add script that starts NGiNX in front of Kibana and tails the NGiNX access/error logs.
ADD bin .
RUN chmod 700 ./run-kibana.sh

EXPOSE 80

CMD ["./run-kibana.sh"]
