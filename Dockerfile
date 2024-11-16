ARG NODE_VERSION=20.18.0
FROM node:${NODE_VERSION}-alpine3.19 AS build

WORKDIR /app

COPY package.json .
RUN npm install --ignore-scripts

COPY . .
RUN npm run build
RUN npm cache clean --force
RUN npm install --only=production --ignore-scripts

FROM node:${NODE_VERSION}-alpine3.19

WORKDIR /app

RUN apk add dumb-init

COPY --chown=node:node --from=build /app/dist .
COPY --chown=node:node --from=build /app/node_modules/ ./node_modules/

ENV NODE_ENV=production

USER node

CMD ["dumb-init", "node", "main"]