FROM clojure:lein-2.9.1 AS BASE

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install --no-install-recommends -yy curl unzip build-essential zlib1g-dev sudo
WORKDIR "/opt"
RUN curl -sLO https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0/graalvm-ce-java11-linux-amd64-21.0.0.tar.gz
RUN tar -xzf graalvm-ce-java11-linux-amd64-21.0.0.tar.gz

ARG BABASHKA_XMX="-J-Xmx4500m"

ENV GRAALVM_HOME="/opt/graalvm-ce-java11-21.0.0"
ENV JAVA_HOME="/opt/graalvm-ce-java11-21.0.0/bin"
ENV PATH="$JAVA_HOME:$PATH"
ENV BABASHKA_XMX=$BABASHKA_XMX

# Make it possible to use Docker to build bb with a particular set of features
# by setting them at build time via `docker build --build-arg ARG_NAME=true ...`
ARG BABASHKA_LEAN=
ARG BABASHKA_FEATURE_CORE_ASYNC=
ARG BABASHKA_FEATURE_CSV=
ARG BABASHKA_FEATURE_JAVA_NIO=
ARG BABASHKA_FEATURE_JAVA_TIME=
ARG BABAHSKA_FEATURE_TRANSIT=
ARG BABASHKA_FEATURE_XML=
ARG BABASHKA_FEATURE_YAML=
ARG BABASHKA_FEATURE_HTTPKIT_CLIENT=
ARG BABASHKA_FEATURE_HTTPKIT_SERVER=
ARG BABASHKA_FEATURE_JDBC=
ARG BABASHKA_FEATURE_POSTGRESQL=
ARG BABASHKA_FEATURE_HSQLDB=
ARG BABASHKA_FEATURE_ORACLEDB=
ARG BABASHKA_FEATURE_DATASCRIPT=
ARG BABASHKA_FEATURE_LANTERNA=
ARG BABASHKA_STATIC=
ENV BABASHKA_LEAN=$BABASHKA_LEAN
ENV BABASHKA_FEATURE_CORE_ASYNC=$BABASHKA_FEATURE_CORE_ASYNC
ENV BABASHKA_FEATURE_CSV=$BABASHKA_FEATURE_CSV
ENV BABASHKA_FEATURE_JAVA_NIO=$BABASHKA_FEATURE_JAVA_NIO
ENV BABASHKA_FEATURE_JAVA_TIME=$BABASHKA_FEATURE_JAVA_TIME
ENV BABAHSKA_FEATURE_TRANSIT=$BABAHSKA_FEATURE_TRANSIT
ENV BABASHKA_FEATURE_XML=$BABASHKA_FEATURE_XML
ENV BABASHKA_FEATURE_YAML=$BABASHKA_FEATURE_YAML
ENV BABASHKA_FEATURE_HTTPKIT_CLIENT=$BABASHKA_FEATURE_HTTPKIT_CLIENT
ENV BABASHKA_FEATURE_HTTPKIT_SERVER=$BABASHKA_FEATURE_HTTPKIT_SERVER
ENV BABASHKA_FEATURE_JDBC=$BABASHKA_FEATURE_JDBC
ENV BABASHKA_FEATURE_POSTGRESQL=$BABASHKA_FEATURE_POSTGRESQL
ENV BABASHKA_FEATURE_HSQLDB=$BABASHKA_FEATURE_HSQLDB
ENV BABASHKA_FEATURE_ORACLEDB=$BABASHKA_FEATURE_ORACLEDB
ENV BABASHKA_FEATURE_DATASCRIPT=$BABASHKA_FEATURE_DATASCRIPT
ENV BABASHKA_FEATURE_LANTERNA=$BABASHKA_FEATURE_LANTERNA
ENV BABASHKA_STATIC=$BABASHKA_STATIC

COPY . .
RUN ./script/uberjar
RUN ./script/compile
RUN ./script/setup-musl

FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl \
        && mkdir -p /usr/local/bin
COPY --from=BASE /opt/bb /usr/local/bin/bb
CMD ["bb"]
