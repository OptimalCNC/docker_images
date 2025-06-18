# Usage

This repository provides two Docker images built via the corresponding Dockerfiles:

- **C++ Tools Base Image**: defined in `cpp_tools.Dockerfile`
- **Qt Image**: defined in `qt.Dockerfile`, based on the C++ Tools Base Image

To use, simply pull the images from GitHub Container Registry:

```bash
docker pull ghcr.io/optimalcnc/docker_images:cpp_tools-22.04
```

## Available Tags

- `cpp_tools-22.04`: Ubuntu 22.04 C++ development tools base image
- `cpp_tools-24.04`: Ubuntu 24.04 C++ development tools base image
- `22.04-qt-6.5.3`: Qt 6.5.3 on Ubuntu 22.04, includes qtbase and ICU
- `22.04-qt-6.4.2`: Qt 6.4.2 on Ubuntu 22.04, includes qtbase and ICU
- `24.04-qt-6.5.3`: Qt 6.5.3 on Ubuntu 24.04, includes qtbase and ICU
- `24.04-qt-6.4.2`: Qt 6.4.2 on Ubuntu 24.04, includes qtbase and ICU

## CI/CD

Image build and release are managed by GitHub Actions workflow: `.github/workflows/docker_release.yml`. The main steps:

1. Define a build matrix for Ubuntu versions (`22.04`, `24.04`) and Qt versions (`6.5.3`, `6.4.2`).
2. Build and push the C++ Tools Base Image (`cpp_tools-<UBUNTU>`).
3. Build and push the Qt Image (`<UBUNTU>-qt-<QT_VERSION>`) based on the base image.
4. Run sample compile tests, then push final Qt images to `ghcr.io/optimalcnc/docker_images`.

## Adding More Qt Components

Only `qtbase` and `icu` are installed by default.

### Add Archives

To install additional archives such as `qtmultimedia`, `qtdeclarative`, and `qtsvg`, run:

```bash
aqt install-qt linux desktop ${QT_VERSION} --archives qtmultimedia qtdeclarative qtsvg --outputdir ${QT_HOME}
```

To list available archives:

```bash
aqt list-qt linux desktop --archives ${QT_VERSION} gcc_64
```

### Add Modules

To install Qt modules such as `qtcharts` or `qtdatavis3d`, use:

```bash
aqt install-qt linux desktop ${QT_VERSION} --archives qtbase --outputdir ${QT_HOME} --modules qtcharts qtdatavis3d
```

To list available modules:

```bash
aqt list-qt linux desktop --long-modules ${QT_VERSION} gcc_64
```

### More Components

You can also install `qt-tools`, `qt-examples`, etc. For full details, refer to the [aqt documentation](https://aqtinstall.readthedocs.io/en/latest/index.html).
