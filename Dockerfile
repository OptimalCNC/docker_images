ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE} as base
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-pip python3-venv \
    git \
    build-essential \
    # Qt dependencies
    libglx-dev libgl1-mesa-dev \
    libglib2.0-0 libxkbcommon0 libfontconfig1 libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/opt/pipx/bin
ENV PIPX_MAN_DIR=/opt/pipx/share/man
ENV PATH=${PIPX_BIN_DIR}:${PATH}
RUN python3 -m pip install --upgrade --no-cache-dir pip && \
    python3 -m pip install --upgrade --no-cache-dir pipx && \
    python3 -m pipx install pre-commit && \
    python3 -m pipx install clang-format==18.1.8 clang-tidy==18.1.8 && \
    python3 -m pipx install cmake && \
    python3 -m pipx install aqtinstall

ARG QT_VERSION
ENV QT_HOME=/opt/Qt
ENV QT_INSTALL_PATH=${QT_HOME}/${QT_VERSION}/gcc_64
ENV QT_VERSION=${QT_VERSION}

FROM base as qt_downloader
RUN aqt install-qt linux desktop ${QT_VERSION} --archives qtbase icu --outputdir "${QT_HOME}"

FROM base
COPY --from=qt_downloader ${QT_HOME} ${QT_HOME}
ENV CMAKE_PREFIX_PATH="${QT_INSTALL_PATH}:${CMAKE_PREFIX_PATH}"
