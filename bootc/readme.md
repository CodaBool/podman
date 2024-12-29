# Bootable Container
NixOS and CoreOS are leading the way for a stateless/immutable OS
The new tech buzz phrase for this is __Move Left__
Meaning more changes happen in the build step

> [!IMPORTANT]  
> Since the OS can be checked into version control
> __The remote registry becomes the source of truth__

This is best targeted for on-prem. linux sys admins
Or in my case self-host hobbyist who like to throw time into Linux

> I missed the kubernetes for a single user plex server phase. So I have to get in on this one

### Details
> as defined by bootc project

- All directories except for `/etc` and `var` are mounted read only
  - state from these 2 paths are preserved across updates
- System can self-update when a new image is available
- Can roll back changes easily
- Can factory reset easily
- Defining disk partitions are still under the deployment step
- compatibility with existing Docker tools
  - this means Docker code scans, validation and signing are all portable to the OS itself in a familiar approach

### Links
- [kickstart](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
- [bootc-image-builder](https://github.com/osbuild/bootc-image-builder)