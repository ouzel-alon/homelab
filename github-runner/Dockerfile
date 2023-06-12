FROM ghcr.io/actions/actions-runner:2.304.0 as build

USER root
RUN apt-get update && apt-get install -y \
    curl jq

USER runner
ADD start.sh start.sh
ENTRYPOINT ["./start.sh"]
