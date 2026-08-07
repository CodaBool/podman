# https://en.wikipedia.org/wiki/Fedora_Linux_release_history
FROM quay.io/fedora/fedora-bootc:44

# I had driver issues but switching to AMD resolved it

RUN dnf update -y && dnf install -y git && dnf clean all
