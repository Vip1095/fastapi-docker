# ─────────────────────────────────────────────────────────────
# Stage 1: Base image
# FROM tells Docker which base image to start from.
# We use the official uv image that already has uv installed.
# ─────────────────────────────────────────────────────────────
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# ─────────────────────────────────────────────────────────────
# WORKDIR sets the working directory inside the container.
# All subsequent commands run from this path.
# ─────────────────────────────────────────────────────────────
WORKDIR /app

# ─────────────────────────────────────────────────────────────
# ENV sets environment variables inside the container.
# UV_COMPILE_BYTECODE=1  → compile .py to .pyc at install time (faster startup)
# UV_LINK_MODE=copy      → copy files instead of symlinks (required in containers)
# ─────────────────────────────────────────────────────────────
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# ─────────────────────────────────────────────────────────────
# COPY copies files from your machine → into the container.
# We copy lock files FIRST (before source code) so Docker can
# cache the dependency install layer. If only code changes,
# Docker skips reinstalling dependencies (faster rebuilds).
# ─────────────────────────────────────────────────────────────
COPY pyproject.toml uv.lock ./

# ─────────────────────────────────────────────────────────────
# RUN executes a shell command during image build.
# We install dependencies from the lockfile (no source code yet).
# --frozen  → fail if uv.lock is out of sync with pyproject.toml
# --no-dev  → skip development dependencies
# ─────────────────────────────────────────────────────────────
RUN uv sync --frozen --no-dev

# ─────────────────────────────────────────────────────────────
# Now copy the rest of the source code.
# Separated from the lock files so dependency cache is reused
# when you only change application code.
# ─────────────────────────────────────────────────────────────
COPY app/ ./app/

# ─────────────────────────────────────────────────────────────
# EXPOSE documents which port the container listens on.
# This is informational only — you still map it with -p at runtime.
# ─────────────────────────────────────────────────────────────
EXPOSE 8000

# ─────────────────────────────────────────────────────────────
# CMD is the default command to run when the container starts.
# uv run → runs the command inside the project's virtual env.
# uvicorn → ASGI server that serves your FastAPI app.
# --host 0.0.0.0 → listen on all network interfaces (required in Docker)
# --port 8000    → port inside the container
# ─────────────────────────────────────────────────────────────
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
