ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV LLVM_TOOL_VERSION=20
ENV LLVM_APT_BASE_URL=https://apt.llvm.org
RUN wget -qO- ${LLVM_APT_BASE_URL}/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    . /etc/os-release && CODENAME=${UBUNTU_CODENAME} && \
    echo "deb ${LLVM_APT_BASE_URL}/${CODENAME}/ llvm-toolchain-${CODENAME}-${LLVM_TOOL_VERSION} main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install --no-install-recommends -y \
        clangd-${LLVM_TOOL_VERSION} \
        clang-tidy-${LLVM_TOOL_VERSION} \
        clang-format-${LLVM_TOOL_VERSION} && \
    ln -s $(which clangd-${LLVM_TOOL_VERSION}) /usr/bin/clangd && \
    ln -s $(which clang-format-${LLVM_TOOL_VERSION}) /usr/bin/clang-format && \
    rm -rf /var/lib/apt/lists/* \

ENV UV_TOOL_BIN_DIR=/opt/uv/bin
ENV UV_TOOL_DIR=/opt/uv/venv
ENV PATH=$UV_TOOL_BIN_DIR:$PATH

COPY --from=ghcr.io/astral-sh/uv:0.6.6 /uv $UV_TOOL_BIN_DIR/

RUN uv tool install pre-commit && \
    uv tool install ruff@0.9.6 && \
    uv tool install cmakelang