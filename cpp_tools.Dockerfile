ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV UV_TOOL_BIN_DIR=/opt/uv/bin
ENV UV_TOOL_DIR=/opt/uv/venv
ENV PATH=$UV_TOOL_BIN_DIR:$PATH

COPY --from=ghcr.io/astral-sh/uv:0.6.6 /uv $UV_TOOL_BIN_DIR/

RUN uv tool install pre-commit && \
    uv tool install clang-format@18.1.8 && \
    uv tool install clang-tidy@18.1.8 && \
    uv tool install ruff@0.9.6 && \
    uv tool install cmake