FROM python:3.11-alpine as base

FROM base as builder

ENV POETRY_NO_INTERACTION=1
RUN pip install poetry

WORKDIR /app

COPY . .
RUN poetry build --format wheel

FROM base as runtime

COPY --from=builder /app/dist/*.whl .
RUN pip install --no-cache-dir *.whl

ENTRYPOINT ["uvicorn", "server.main:app", "--host", "0.0.0.0"]