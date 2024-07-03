FROM node:lts AS builder

ARG API_HOST="http://localhost:8000"
ARG COMMIT="latest"

RUN corepack enable

WORKDIR /app

COPY . .

ENV VITE_API_HOST=$API_HOST \
    VITE_COMMIT=$COMMIT

RUN pnpm install
RUN pnpm build

FROM nginx:stable

COPY --from=builder /app/dist /usr/share/nginx/html
