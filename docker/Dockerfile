### Webapp build
FROM node:16.3.0@sha256:ca6daf1543242acb0ca59ff425509eab7defb9452f6ae07c156893db06c7a9a4 as nodebuild

WORKDIR /webapp
ADD webapp/ /webapp

### 'CPPFLAGS="-DPNG_ARM_NEON_OPT=0"' Needed To Avoid Bug Described in: https://github.com/imagemin/optipng-bin/issues/118#issuecomment-1019838562
### Can be Removed when Ticket will be Closed
RUN CPPFLAGS="-DPNG_ARM_NEON_OPT=0" npm install --no-optional && \
    npm run pack

### Go build
FROM golang:1.21.8 AS gobuild

WORKDIR /go/src/focalboard
ADD . /go/src/focalboard

# Get target architecture 
ARG TARGETOS
ARG TARGETARCH  
ARG SKIP_TESTS=false

# Skip tests if the SKIP_TESTS arg is true
RUN if [ "$SKIP_TESTS" = "true" ]; then \
    EXCLUDE_PLUGIN=true EXCLUDE_SERVER=true EXCLUDE_ENTERPRISE=true EXCLUDE_TESTS=true make server-docker os=${TARGETOS} arch=${TARGETARCH}; \
  else \
    EXCLUDE_PLUGIN=true EXCLUDE_SERVER=true EXCLUDE_ENTERPRISE=true make server-docker os=${TARGETOS} arch=${TARGETARCH}; \
  fi

## Final image
FROM debian:bookworm-slim

# Install SQLite tools
RUN apt-get update && apt-get install -y sqlite3 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/focalboard/data/files
RUN chown -R nobody:nogroup /opt/focalboard

WORKDIR /opt/focalboard

COPY --from=nodebuild --chown=nobody:nogroup /webapp/pack pack/
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/bin/docker/focalboard-server bin/
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/LICENSE.txt LICENSE.txt
COPY --from=gobuild --chown=nobody:nogroup /go/src/focalboard/docker/server_config.json config.json

# Add startup script
COPY --chown=nobody:nogroup docker/startup.sh /opt/focalboard/bin/startup.sh
RUN chmod +x /opt/focalboard/bin/startup.sh

USER nobody

EXPOSE 8000/tcp

EXPOSE 8000/tcp 9092/tcp

VOLUME /opt/focalboard/data

CMD ["/opt/focalboard/bin/startup.sh"]
