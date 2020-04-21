
FROM ubuntu:latest

RUN apt-get update --fix-missing -q  \
  && apt-get install -yqq \
  curl \
  jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ../tfe-scripts/tf-add-app-run.sh /script.sh
