# Start from gcloud image
FROM google/cloud-sdk

# Install dependencies
RUN apt-get update && \
    apt-get -qqy install curl unzip

ARG TERRAFORM_VERSION=0.12.26
# Install terraform for linux
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/