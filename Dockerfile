FROM adoptopenjdk/openjdk8:alpine-jre

ENV STRUCTURIZR_VERSION 1.5.1

# Create app directory
WORKDIR /root/structurizr

RUN set -e; \
    apk add --no-cache bash && \
    wget https://github.com/structurizr/cli/releases/download/v${STRUCTURIZR_VERSION}/structurizr-cli-${STRUCTURIZR_VERSION}.zip && \
    unzip structurizr-cli-${STRUCTURIZR_VERSION}.zip && \
    ln -s structurizr-cli-${STRUCTURIZR_VERSION}.jar structurizr-cli.jar && \
    rm structurizr-cli-${STRUCTURIZR_VERSION}.zip

ENTRYPOINT [ "bash", "/root/structurizr/structurizr.sh" ]
