FROM icr.io/appcafe/websphere-liberty:full-java17-openj9-ubi

USER root

RUN dnf install -y nc && dnf clean all

WORKDIR /opt

COPY --chown=1001:0 Tririga /opt/tririga
COPY --chown=1001:0 data.zip /opt/tririga/data.zip

COPY start-server.sh /start-server.sh
RUN chmod +x /start-server.sh

USER 1001

WORKDIR /opt/tririga

EXPOSE 8001 8443

CMD ["/start-server.sh"]