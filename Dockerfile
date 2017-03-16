FROM quay.io/aptible/ubuntu:14.04

# Install NGiNX.
RUN apt-get update && \
    apt-get install -y software-properties-common \
    python-software-properties && \
    add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get -y install curl ucspi-tcp apache2-utils nginx ruby

ENV KIBANA_5_VERSION 5.2.2
ENV KIBANA_5_SHA1SUM a9c9a74a0684756bced3d0009a09a4006e5b258e

# Kibana 5
RUN curl -fsSLO "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" && \
    echo "${KIBANA_5_SHA1SUM}  kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" | sha1sum -c - && \
    tar xzf "kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz" -C /opt && \
    mv "/opt/kibana-${KIBANA_5_VERSION}-linux-x86_64" "/opt/kibana-${KIBANA_5_VERSION}" && \
    rm "kibana-${KIBANA_5_VERSION}-linux-x86_64.tar.gz"

# Overwrite default nginx config with our config.
RUN rm /etc/nginx/sites-enabled/*
ADD templates/sites-enabled /

RUN rm "/opt/kibana-${KIBANA_5_VERSION}/config/kibana.yml"

ADD templates/opt/kibana-5.x/ /opt/kibana-${KIBANA_5_VERSION}/config

# Add script that starts NGiNX in front of Kibana and tails the NGiNX access/error logs.
ADD bin .
RUN chmod 700 ./run-kibana.sh

EXPOSE 80

CMD ["./run-kibana.sh"]
