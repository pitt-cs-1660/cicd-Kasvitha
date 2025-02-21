# Stage 1: Build Dependencies
FROM python:3.11-buster AS builder

WORKDIR /app

# Set environment variables for better logging
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip && pip install poetry

# Copy dependency files first to cache them efficiently
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction --no-ansi

# Now copy the entire project
COPY . .

# Stage 2: Final Image
FROM python:3.11-buster AS app

WORKDIR /app

# Create a non-root user for security
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -m appuser

COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/poetry /usr/local/bin/poetry

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

# Use exec form for better signal handling in Docker
CMD ["uvicorn", "cc_compose.server:app", "--host", "0.0.0.0", "--port", "8000"]
