ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

ENV LLVM_TOOL_VERSION=20
ENV LLVM_APT_BASE_URL=https://apt.llvm.org

RUN apt-get update && \
    apt-get install -y gnupg wget ca-certificates build-essential && \
    wget -qO- ${LLVM_APT_BASE_URL}/llvm-snapshot.gpg.key \
      | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
    . /etc/os-release && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] \
      ${LLVM_APT_BASE_URL}/${UBUNTU_CODENAME}/ \
      llvm-toolchain-${VERSION_CODENAME}-${LLVM_TOOL_VERSION} main" \
      > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
      clangd-${LLVM_TOOL_VERSION} \
      clang-tidy-${LLVM_TOOL_VERSION} \
      clang-format-${LLVM_TOOL_VERSION} && \
    rm -rf /var/lib/apt/lists/*

#—— Create Versionless Alias Commands for clang Tools ——
RUN update-alternatives --install /usr/bin/clang-format clang-format \
      /usr/bin/clang-format-${LLVM_TOOL_VERSION} ${LLVM_TOOL_VERSION} \
 && update-alternatives --install /usr/bin/clang-tidy   clang-tidy   \
      /usr/bin/clang-tidy-${LLVM_TOOL_VERSION}   ${LLVM_TOOL_VERSION} \
 && update-alternatives --install /usr/bin/clangd       clangd       \
      /usr/bin/clangd-${LLVM_TOOL_VERSION}         ${LLVM_TOOL_VERSION}

ENV UV_TOOL_BIN_DIR=/opt/uv/bin
ENV UV_TOOL_DIR=/opt/uv/venv
ENV PATH=$UV_TOOL_BIN_DIR:$PATH

COPY --from=ghcr.io/astral-sh/uv:0.7.13 /uv $UV_TOOL_BIN_DIR/

RUN uv tool install pre-commit && \
    uv tool install ruff@0.12.0 && \
    uv tool install cmakelang