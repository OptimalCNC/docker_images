ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    ca-certificates \
    build-essential \
    cmake \
    curl zip unzip tar pkg-config \
    && rm -rf /var/lib/apt/lists/*

# vcpkg
# the cache dir of vcpkg is meant to be static.
# thus, we do not place it under ${CACHE_DIR} which is suggested to be mounted as a volume in devcontainer.
ENV VCPKG_ROOT=/opt/vcpkg
ENV VCPKG_CACHE_DIR=${VCPKG_ROOT}/cache
ENV VCPKG_BINARY_CACHE_PATH=${VCPKG_CACHE_DIR}/binary
ENV VCPKG_ASSET_CACHE_PATH=${VCPKG_CACHE_DIR}/asset
ENV VCPKG_DEFAULT_BINARY_CACHE=${VCPKG_BINARY_CACHE_PATH}
ENV VCPKG_DOWNLOADS=${VCPKG_ASSET_CACHE_PATH}
ENV VCPKG_FEATURE_FLAGS=manifests,registries,binarycaching
ENV VCPKG_BINARY_SOURCES=clear;files,${VCPKG_BINARY_CACHE_PATH},readwrite
ENV VCPKG_ASSET_SOURCES=clear;x-assetcache,${VCPKG_ASSET_CACHE_PATH}
ENV X_VCPKG_REGISTRIES_CACHE=${VCPKG_CACHE_DIR}/registries
ENV PATH=${VCPKG_ROOT}:$PATH
ENV CMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
# According to how vcpkg versioning works, we need a full clone of the repository.
# https://learn.microsoft.com/en-us/vcpkg/users/versioning-troubleshooting#shallow-clone-version-constraint
RUN git clone https://github.com/microsoft/vcpkg.git ${VCPKG_ROOT} && \
    cd ${VCPKG_ROOT} && \
    ./bootstrap-vcpkg.sh -disableMetrics && \
    mkdir -p ${X_VCPKG_REGISTRIES_CACHE} \
             ${VCPKG_BINARY_CACHE_PATH} \
             ${VCPKG_ASSET_CACHE_PATH}

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