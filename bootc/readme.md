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

- All directories except for `/etc` and `/var` are mounted read only
  - files under these 2 paths are preserved across updates
  - `/var/home/` is a symlink to `/home` so `/home` is effectively preserved as well
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

---

# bashrc

```sh
alias large="find . -type f -size +50M -exec du -h {} \; | sort -n"
alias size="du -sh -- *"
alias c="cd /home/codabool/.config/containers/systemd/ && ls -lah"
alias v="cd /mnt/volumes/ && ls -lah"
alias r="podman restart $@"
alias s="podman stop $@"
alias f="podman logs -f $@"
alias e="podman logs $@"

p() {
    local DRY=false
    if [[ "$1" == "--dry" ]]; then
        DRY=true
    fi

    local TARGET="../$(basename "$PWD")"

    local CHOWN_CMD="sudo chown -R 1000:1000 \"$TARGET\""
    local CHMOD_CMD="sudo chmod -R 755 \"$TARGET\""

    if [[ "$DRY" == true ]]; then
        echo "[Dry Run] Would execute:"
        echo "  $CHOWN_CMD"
        echo "  $CHMOD_CMD"
    else
        echo "Executing:"
        echo "  $CHOWN_CMD"
        eval "$CHOWN_CMD"

        echo "  $CHMOD_CMD"
        eval "$CHMOD_CMD"
    fi
}
```
