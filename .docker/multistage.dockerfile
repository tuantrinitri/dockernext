# Build BASE
FROM node:16-alpine as BASE
LABEL author="tuantrinitri <quoctuanit.282@gmail.com>"

WORKDIR /appp
COPY package.json yarn.lock ./
RUN apk add --no-cache git \
    && yarn install --frozen-lockfile \
    && yarn cache clean

# Build Image
FROM node:16-alpine AS BUILD
LABEL author="tuantrinitri <quoctuanit.282@gmail.com>"

WORKDIR /appp
COPY --from=BASE /appp/node_modules ./node_modules
COPY . .
RUN apk add --no-cache git curl \
    && curl -sf https://gobinaries.com/tj/node-prune | sh \
    && apk del curl
RUN  yarn build \
    && rm -rf node_modules \
    && yarn install --production --frozen-lockfile --ignore-scripts --prefer-offline \
    && node-prune 


# Build production
FROM node:16-alpine AS PRODUCTION
LABEL author="tuantrinitri <quoctuanit.282@gmail.com>"

WORKDIR /appp

COPY --from=BUILD /appp/package.json /appp/yarn.lock ./
COPY --from=BUILD /appp/node_modules ./node_modules
COPY --from=BUILD /appp/.next ./.next
COPY --from=BUILD /appp/public ./public
# COPY --from=BUILD /appp/next.config.js ./

EXPOSE 3000

CMD ["yarn", "start"]
