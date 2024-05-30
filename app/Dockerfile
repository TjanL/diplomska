FROM node:lts as builder

ARG API_HOST="http://localhost:8000"
ARG COMMIT=""

RUN corepack enable

WORKDIR /app

COPY . .
RUN pnpm install --prod --frozen-lockfile
RUN pnpm build

FROM nginx:stable

COPY --from=builder /app/dist /usr/share/nginx/html
