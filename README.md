# Usage

This repository provides an image with Qt 6.5.3 installed on Ubuntu 22.04.

To use, simply pull the image from Docker Hub:

```bash
docker pull ghcr.io/optimalcnc/qt_image:24.04-6.4.2
```

Available tags:
- `22.04-6.5.3`: Qt 6.5.3 on Ubuntu 22.04 with qtbase component and development tools
- `22.04-6.4.2`: Qt 6.4.2 on Ubuntu 22.04 with qtbase component and development tools
- `24.04-6.5.3`: Qt 6.5.3 on Ubuntu 24.04 with qtbase component and development tools
- `24.04-6.4.2`: Qt 6.4.2 on Ubuntu 24.04 with qtbase component and development tools

## Adding more Qt components

### archives
In the image, we specify to only install `qtbase` and `icu` archives.
If you want to install more components, you can use the `aqt` command, e.g. for `qtmultimedia`, `qtdeclarative`, and `qtsvg`:

```bash
aqt install-qt linux desktop ${QT_VERSION} --archives qtmultimedia qtdeclarative qtsvg --outputdir ${QT_HOME}
```

See the output of `apt list-qt linux desktop --archives ${QT_VERSION} gcc_64` for the available archives.

### modules
To add more modules, e.g. for `qtcharts` and `qtdatavis3d`:

```bash
aqt install-qt linux desktop ${QT_VERSION} --archives qtbase --outputdir ${QT_HOME} --modules qtcharts qtdatavis3d
```

See the output of `aqt list-qt linux desktop --long-modules ${QT_VERSION} gcc_64` for the available archives.

### more components

One can also add `qt-tools`, `qt-examples`, etc., see [aqt documentation](https://aqtinstall.readthedocs.io/en/latest/index.html) for more information.
