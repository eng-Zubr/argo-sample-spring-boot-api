FROM python:3.11.9-bullseye

MAINTAINER Alex Burym

ARG PLATFORM_NAME
ARG PLATFORM_NAME_ALTERNATE
ARG AWS_CLI_VER
ARG TERRAFORM_VER
ARG TERRAGRUNT_VER
ARG KUBECTL_VER
ARG K9S_VER
ARG HELM_VER
ARG SSH_KEY_NAME
ARG NODE_VERSION
ENV SSH_KEY=$SSH_KEY_NAME

RUN apt update && apt install -y curl unzip git ca-certificates vim nano && rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$PLATFORM_NAME_ALTERNATE-$AWS_CLI_VER.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && rm awscliv2.zip && \
    ./aws/install
    
RUN curl "https://releases.hashicorp.com/terraform/{$TERRAFORM_VER}/terraform_{$TERRAFORM_VER}_linux_{$PLATFORM_NAME}.zip" \
    -o "terraform.zip" && \
    unzip terraform.zip && rm terraform.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin/terraform
    
RUN curl -o /usr/bin/terragrunt \
    -LO "https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VER/terragrunt_linux_$PLATFORM_NAME" \
    && chmod +x /usr/bin/terragrunt

RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$PLATFORM_NAME && \
    chmod +x /usr/local/bin/argocd
    
RUN curl -LO "https://dl.k8s.io/release/v$KUBECTL_VER/bin/linux/$PLATFORM_NAME/kubectl" -o "kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/bin/kubectl

RUN curl -o k9s.tar.gz \
    -LO "https://github.com/derailed/k9s/releases/download/v$K9S_VER/k9s_Linux_$PLATFORM_NAME.tar.gz" && \
    tar -zxvf k9s.tar.gz && rm k9s.tar.gz && \
    chmod +x k9s && \
    mv k9s /usr/bin/k9s

RUN curl -o helm.tar.gz \
    -LO "https://get.helm.sh/helm-v$HELM_VER-linux-$PLATFORM_NAME.tar.gz" \
    && tar -zxvf helm.tar.gz && rm helm.tar.gz && \
    mv linux-$PLATFORM_NAME/helm /usr/bin/helm

RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$PLATFORM_NAME && \
    chmod +x /usr/local/bin/argocd

RUN mkdir -p /devsecops-terraform-aws

WORKDIR /devsecops-terragrunt-aws

RUN date && echo "\n--------------------------------------------------------------------------------------------------------\naws:" && \
    aws --version && echo "\n--------------------------------------------------------------------------------------------------------\nterraform:" && \
    terraform --version && echo "\n--------------------------------------------------------------------------------------------------------\nterragrunt:" && \
    terragrunt --version && echo "\n--------------------------------------------------------------------------------------------------------\nhelm:" && \
    helm version

ENTRYPOINT ["/devsecops-terragrunt-aws/docker_entrypoint.sh", "$SSH_KEY"]

