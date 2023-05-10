# HandBrake Build Dockerfiles

These Dockerfiles can be used to test the HandBrake build process in a container environment, in order to keep the dependency lists up to date.
They can also be used to generate binaries.

### Example usage
First install podman or docker.
Testing the build process:

```
podman build --target test ubuntu
```
The CLI is built seperately before the GUI dependencies are installed, so that both CLI and GUI dependency lists are tested in a single run.

Building binaries:

```
podman build --output _build fedora
```

Produces a directory named `_build` in the current directory containing the installation files.

Alternative image versions:

```
podman build --from rockylinux:latest --output _build el
```
Builds the `el` image using Rocky Linux as the base instead of the default AlmaLinux.
Some alternative image names are listed below.

### Platforms

#### Linux
Distributions without a checkmark don't have official Docker images at the moment.

- [x] Alpine Linux
- [x] Arch Linux
- [x] CentOS Stream (`centos:stream9`, `centos:stream8`)
- [x] Clear Linux
- [x] Debian
- [x] Enterprise Linux (`almalinux:9`, `rockylinux:latest`)
- [x] Fedora
- [ ] Gentoo
- [x] OpenSUSE (`opensuse/leap:latest`, `opensuse/tumbleweed:latest`)
- [x] Ubuntu
- [ ] Void

### Targets
- `test-cli`: Test building with CLI dependencies.
- `test`: Test building with CLI and GUI dependencies.
- `binaries` (default): CLI and GTK GUI binaries, as well as extra files.
- `binaries-cli`: CLI binary only.

### Build Arguments
Use with `--build-arg ARG=value`.

- `GIT_TAG`: The tag to checkout from GitHub (default: master).
- `PREFIX`: The prefix where the binaries will be installed (default: /usr/local).

### Notes
- Docker images don't include sudo. If building on a live OS, the commands in the Dockerfiles won't work.
- Building the images uses a large amount of space. The cached images can be deleted after use.
