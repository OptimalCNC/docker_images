ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE} as base
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    build-essential \
    # Qt dependencies
    libglx-dev libgl1-mesa-dev \
    libglib2.0-0 libxkbcommon0 libfontconfig1 libdbus-1-3 \
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

ARG QT_VERSION
ENV QT_HOME=/opt/Qt
ENV QT_INSTALL_PATH=${QT_HOME}/${QT_VERSION}/gcc_64
ENV QT_VERSION=${QT_VERSION}

FROM base as qt_downloader
RUN uv tool run --from aqtinstall aqt install-qt linux desktop ${QT_VERSION} --archives qtbase icu --outputdir "${QT_HOME}"

FROM base
COPY --from=qt_downloader ${QT_HOME} ${QT_HOME}
ENV CMAKE_PREFIX_PATH="${QT_INSTALL_PATH}:${CMAKE_PREFIX_PATH}"
