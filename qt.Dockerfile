ARG BASE_IMAGE=cpp_tools:latest
ARG QT_VERSION
FROM ${BASE_IMAGE} as base

ENV QT_HOME=/opt/Qt
    QT_INSTALL_PATH=${QT_HOME}/${QT_VERSION}/gcc_64
ENV QT_VERSION=${QT_VERSION}

RUN apt-get update && apt-get install --no-install-recommends -y \
    libglx-dev \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libxkbcommon0 \
    libfontconfig1 \
    libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

FROM base as qt_downloader
RUN uv tool run --from aqtinstall aqt install-qt linux desktop ${QT_VERSION} \
    --archives qtbase icu \
    --outputdir "${QT_HOME}"

FROM base
COPY --from=qt_downloader ${QT_HOME} ${QT_HOME}
ENV CMAKE_PREFIX_PATH=${QT_INSTALL_PATH}:${CMAKE_PREFIX_PATH}