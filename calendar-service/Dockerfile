FROM node:current-alpine3.17

WORKDIR /app

RUN apk add tini

COPY package*.json ./

RUN npm install

WORKDIR /app/calendar-service

EXPOSE 8000

ENTRYPOINT ["tini", "--"]
