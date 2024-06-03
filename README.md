<!-- badges: start -->
<!-- badges: end -->

This is a `Dockerised` version of [`Cecelia`](https://github.com/schienstockd/cecelia).
We currently do not include `napari` in the container. That means, we have to install
a separate `conda` environment with which the `Docker container` can communicate.

**This package is pre-alpha**

We currently have no pre-build containers.
This repository will build the `Docker container`.

## Installation

- Install [`miniconda`](https://docs.conda.io/en/latest/miniconda.html)

- Clone this repository or download the
[`zip file`](https://github.com/schienstockd/ceceliaDocker/archive/refs/heads/master.zip)
``` bash
git clone https://github.com/schienstockd/ceceliaDocker.git
```

- For `Windows`, you will need to [install JDK](https://www.oracle.com/au/java/technologies/javase/javase8-archive-downloads.html) and [Microsoft Visual C++ >= 14.0](https://visualstudio.microsoft.com/visual-cpp-build-tools/) with Microsoft C++ Build Tools.
Docker is using `WSL 2` by default now which is also required for `GPU` access on Windows.
To change the default location of the `WSL 2` data storage follow this [`SO`](https://stackoverflow.com/a/63752264) post. You also need either at least `Windows 11`
or the [`19044.1200 (21H2) Windows 10 Insider Preview Build`](https://blogs.windows.com/windows-insider/2021/08/18/announcing-windows-10-insider-preview-build-19044-1198-21h2/) for `GPU` support via `WSL 2`. You can sign up [here](https://insider.windows.com/en-us/register).

- Create `conda` environment

``` bash
conda env create --file=conda-gui-env.yml
```

- If you have an `NVIDIA` GPU and want to use it, you need to rename
`docker-compose.yml` to `docker-compose.cpu.yml` and
`docker-compose.nvidia.yml` to `docker-compose.yml`. To check that your `GPU` is detected
by Docker use: `docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark`.

- You need to adjust the filepaths in `docker-compose.yml` and `datashare/docker.yml`.
This will tell `Docker` where your `projects` are stored and the `data` location
that you can use to import data. We also need to tell `shiny` to use the host directory
to open images as they are opened outside of the container within the `napari` environment.

Windows example `docker-compose.yml`
```yaml
services:
  app:
    volumes:
      - C:\Users\schienstockd\ceceliaDocker\datashare:/home/shiny/local
      - E:\Cecelia\Dominik\projects:/cecelia/projects
      - E:\Cecelia\Dominik\data:/cecelia/data
```

Windows example `datashare/docker.yml`
```yaml
default:
  docker:
    useDocker: TRUE
    pathMapping:
      from:
        - "/cecelia/projects"
      to:
        - "E:\\Cecelia\\Dominik\\projects"
```

- Run (and build) the `Docker container` with `cecelia-MacOSX-docker.command` (Mac)
or `cecelia-Windows-docker.bat` (Windows). This will start the local `napari` environment,
build the `Docker container` during the first run and start the `app`.
At the moment, the container will update the app whenever it is changed on github.
There are two `Dockerfiles`. The default pulls the current Docker image from
Dockerhub. `Dockerfile.build` will build the container if you wish to do that.
