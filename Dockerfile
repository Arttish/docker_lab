FROM alpine:3.21 AS base

WORKDIR /app

RUN apk add --no-cache --virtual .build-deps git

FROM base AS builder 

RUN apk add --no-cache --virtual .build-deps nodejs npm make go

COPY ./src /app
RUN make frontend
RUN TAGS="bindata" make build

FROM base

WORKDIR /app

RUN adduser gitea --disabled-password

ARG GITEA_PORT=3000
ARG MYSQL_DB_HOST=localhost:3306
ARG MYSQL_DB_NAME=gitea
ARG MYSQL_DB_USER=gitea
ARG MYSQL_DB_PASSWORD=pass

ENV GITEA_PORT=${GITEA_PORT}
ENV MYSQL_DB_HOST=${MYSQL_DB_HOST}
ENV MYSQL_DB_NAME=${MYSQL_DB_NAME}
ENV MYSQL_DB_USER=${MYSQL_DB_USER}
ENV MYSQL_DB_PASSWORD=${MYSQL_DB_PASSWORD}

COPY --from=builder /app/gitea /app/gitea


RUN cat > /app/app.ini <<EOF

[server]
HTTP_ADDR = 0.0.0.0
HTTP_PORT = $GITEA_PORT
DISABLE_SSH = true

[database]
DB_TYPE = mysql
HOST = $MYSQL_DB_HOST
NAME = $MYSQL_DB_NAME
USER = $MYSQL_DB_USER
PASSWD = $MYSQL_DB_PASSWORD

[security]
INSTALL_LOCK = true
SECRET_KEY = 12345
INTERNAL_TOKEN = 54321

[oauth2]
ENABLED = false

[log]
MODE = console
LEVEL = Info

EOF

RUN chown gitea:gitea -R /app
USER gitea

ENTRYPOINT ["./gitea" ]
CMD [ "web", "--config=/app/app.ini", "--custom-path=/data", "-w=/tmp" ]