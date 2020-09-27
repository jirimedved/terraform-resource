FROM ljfranklin/terraform-resource:0.13.3 as base
LABEL maintainer="Jiri Medved <admin@jirimedved.cz>"
RUN apk update \
    && apk upgrade

# Terraform Libvirt Plugin
FROM golang:1.13-alpine AS libvirt
RUN apk update \
    && apk upgrade \
    && apk add --no-cache git make gcc pkgconfig libvirt-dev libc-dev \
    && mkdir -p /build \
    && mkdir -p /dist

WORKDIR /build 
RUN git clone https://github.com/dmacvicar/terraform-provider-libvirt.git
WORKDIR /build/terraform-provider-libvirt
RUN git checkout v0.6.2 && env GO111MODULE=on go mod download \
    && make build && mv terraform-provider-libvirt /dist/terraform-provider-libvirt

FROM base AS tools
RUN apk add jq=1.6-r1 \
    && mkdir -p /root/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64/ \
    && apk add libvirt gcc libxslt cdrkit \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*
COPY --from=libvirt /dist/terraform-provider-libvirt /root/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64/