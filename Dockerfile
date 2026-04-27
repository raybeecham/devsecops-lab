# Multi-stage build — production container is smaller
FROM python:3.12-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage - minimal image
FROM python:3.12-slim

# Non-root user for security
RUN useradd -m - u 1000 appuser

WORKDIR /app

# Copy only what we need from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

# Set permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add local pip packages to PATH
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000

CMD ["python", "app.py"]