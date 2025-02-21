FROM python:3.11-buster AS builder

WORKDIR /app

RUN pip install --upgrade pip && pip install poetry

COPY . .

RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi \
    && pip install uvicorn  # Ensure Uvicorn is installed globally

FROM python:3.11-buster AS app

WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/poetry /usr/local/bin/poetry

EXPOSE 8000

CMD ["poetry", "run", "uvicorn", "cc_compose.server:app", "--host", "0.0.0.0", "--port", "8000"]
