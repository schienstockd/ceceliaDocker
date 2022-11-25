<!-- badges: start -->
<!-- badges: end -->

This is a `Dockerised` version of [`Cecelia`](https://github.com/schienstockd/cecelia).
We currently did not includ in the container `napari`. That means, we have to install
a separate `conda` environment with which the `Docker container` can communicate.

**This package is pre-alpha**

## Installation

- Install [`miniconda`](https://docs.conda.io/en/latest/miniconda.html)

- Clone this repository or download the
[`zip file`](https://github.com/schienstockd/ceceliaDocker/archive/refs/heads/master.zip)
``` bash
git clone https://github.com/schienstockd/ceceliaDocker.git
```

- For `Windows`, you will need the following:

```
- Install JDK: https://www.oracle.com/au/java/technologies/javase/javase8-archive-downloads.html
- Install Microsoft Visual C++ >= 14.0 with Microsoft C++ Build Tools: https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

- Create `conda` environment

``` bash
conda env create --file=conda-gui-env.yml
```

- Run (and build) the `Docker container` with
`cecelia-MacOSX-docker.sh` (Mac)
or `cecelia-Windows-docker.bat` (Windows). This will start the local `napari` environment,
build the `Docker container` during the first run and start the `app`.
At the moment, the container will update the app whenever it is changed on github.
