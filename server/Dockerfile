FROM python:3.11-alpine AS base

FROM base AS builder

ENV POETRY_NO_INTERACTION=1
RUN pip install poetry

WORKDIR /app

COPY . .
RUN poetry build --format wheel

FROM base AS runtime

COPY --from=builder /app/dist/*.whl .
RUN pip install --no-cache-dir *.whl

ENTRYPOINT ["uvicorn", "server.main:app", "--host", "0.0.0.0"]
