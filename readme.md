# qbit
needed to add a SELinux policy as mentioned [here](https://github.com/qdm12/gluetun-wiki/blob/main/errors/tun.md#tun-device-is-not-available-open-devnettun-permission-denied)

otherwise would needto add in

```
PodmanArgs=--privileged
```
