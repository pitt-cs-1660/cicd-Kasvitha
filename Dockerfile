# Use the official Python image
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

# Use Poetry to ensure Uvicorn starts correctly
CMD ["poetry", "run", "uvicorn", "cc_compose.server:app", "--host", "0.0.0.0", "--port", "8000"]
