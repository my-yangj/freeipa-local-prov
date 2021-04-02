FROM centos:centos8.3.2011
COPY freeipa.setup.sh .
RUN ./freeipa.setup.sh