# Bootable Container
NixOS and CoreOS are leading the way for a stateless/immutable OS

The new tech buzz phrase for this is __Move Left__

Meaning more changes happen in the build step

> [!IMPORTANT]
> Since the OS can be checked into version control
> __The remote registry becomes the source of truth__

## File responsibilities
### Dockerfile
  - distro
  - user packages
### kickstart
  - users & groups
  - ssh key
  - partitioning
  - bootloader
  - network
  - mounts
# Bootc Details
> as defined by bootc project

- All directories except for `/etc` and `var` are mounted read only
  - files under these 2 paths are preserved across updates
- System can self-update when a new image is available
- Supports roll backs
- Easy factory resets
- Defining disk partitions are still under the deployment step
- compatibility with existing Docker tools
  - this means Docker code scans, validation and signing are all portable to the OS itself in a familiar approach


### Commands
- bootc upgrade --check (check for a new image)
- bootc upgrade --apply (will restart into new image)
- bootc status (see info about current image)

### Links
- [kickstart](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
- [bootc-image-builder](https://github.com/osbuild/bootc-image-builder)
- [bootc docs](https://containers.github.io/bootc)
