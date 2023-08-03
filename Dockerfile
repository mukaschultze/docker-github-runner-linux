# base image
FROM ubuntu:20.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl nodejs wget unzip vim git azure-cli jq build-essential \
        libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip && \
    apt-get clean && \
    apt-get autoremove -y

WORKDIR ./github-actions

RUN mkdir actions-runner && \
    cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN useradd -m runner && \
    chown -R runner . && \
    ./actions-runner/bin/installdependencies.sh

# add over the start.sh script
COPY scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "runner" so all subsequent commands are run as the runner user
USER runner

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]