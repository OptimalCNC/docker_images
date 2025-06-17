ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV LLVM_TOOL_VERSION=20
ENV LLVM_APT_BASE_URL=https://apt.llvm.org

RUN apt-get update && \
    apt-get install -y gnupg wget ca-certificates build-essential && \
    wget -qO- ${LLVM_APT_BASE_URL}/llvm-snapshot.gpg.key \
      | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] \
      ${LLVM_APT_BASE_URL}/${UBUNTU_CODENAME}/ \
      llvm-toolchain-${UBUNTU_CODENAME}-${LLVM_TOOL_VERSION} main" \
      > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
      clangd-${LLVM_TOOL_VERSION} \
      clang-tidy-${LLVM_TOOL_VERSION} \
      clang-format-${LLVM_TOOL_VERSION} && \
    rm -rf /var/lib/apt/lists/*

ENV UV_TOOL_BIN_DIR=/opt/uv/bin
ENV UV_TOOL_DIR=/opt/uv/venv
ENV PATH=$UV_TOOL_BIN_DIR:$PATH

COPY --from=ghcr.io/astral-sh/uv:0.6.6 /uv $UV_TOOL_BIN_DIR/

RUN uv tool install pre-commit && \
    uv tool install ruff@0.9.6 && \
    uv tool install cmakelang