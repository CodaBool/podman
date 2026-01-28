# Podman Self-Host
<a href="https://www.youtube.com/watch?v=2H5lqPRPNhA">
  <img src="https://github.com/CodaBool/stargazer/blob/main/public/pom.gif?raw=true" style="height:70px;">
</a>

```
         .--"--.           
       / -     - \         
      / (O)   (O) \        
   ~~~| -=(,Y,)=- |       
    .---. /`  \   |~~      
 ~/  o  o \~~~~.----. ~~  don't talk to us    
  | =(X)= |~  / (O (O) \   
   ~~~~~~~  ~| =(Y_)=-  |   
  ~~~~    ~~~|   U      |~~ 
```
> Podman is a (more secure and performant) Docker alternative

## How does it work?
When a `.container` file is placed into `/.config/containers/systemd` 
it automatically becomes a systemd service 🪄

## Structure
> I have a RAID 1 HDD with this structure
```
└── mnt/
    └── volumes/
        ├── container_name
        └── .container_name.env
```

## Security
- [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks) provided by the tunnel container
- CloudFlare WAF blocking non-US traffic

## Automatic Updates
> The fedora bootc image ships with auto update timers. These do `podman auto-update` daily and then `podman image prune -f`. If the container fails to start after auto-update, then it will automatically be rolled back.

1. add `AutoUpdate=registry` to your `.Container` file
2. [optional for me] normally you have to run `systemctl --user enable --now podman-auto-update.timer` but I have this enabled by default from my kickstart config

## Automatic run on boot
by default services will not run unless the user is logged in. This allows the service to run anytime

`loginctl enable-linger $USER`

> optional for me since I have enabled linger from my kickstart config

## Quadlet Validation
- `/usr/libexec/podman/quadlet --user --dryrun`
- `/usr/lib/systemd/system-generators/podman-system-generator --user --dryrun`
- `systemd-analyze --user --generators=true verify rss.service`

## Expose Podman socket
written to `/run/user/1000/podman/podman.sock`

`systemctl --user enable --now podman.socket`

> optional for me since I have exposed the podman socket in my kickstart config

## Stats
- GPU (AMD): `podman run --rm -it --privileged docker.io/joonas/radeontop`
- CPU & Memory
  - `podman stats CONTAINER_NAME`
  - `podman stats`

## Permission Debug
`ausearch -i -m avc`, shows what SELinux policy is blocking. If empty then your problem is not SELinux related.

You can temporarily run a container with SELinux disabled `--security-opt=label=disable` or `PodmanArgs=--privileged`

`ps` outside the container can show what UID the container runs as, then confirm that this user is able to access your files.

You can also use `strace -p <pid> --decode-fds=all` on the process to observe exactly which system call is returning an error to the application.


# Services
> I use changedetector to find any changes to any pinned image tags

```md
├── uptime:latest
├── tunnel:latest
├── tools:latest
├── pastebin:latest
├── jellyfin:latest
├── foundry_2:latest
├── foundry_1:13
├── r2_to_vtt:latest (custom image, pushed weekly) [https://github.com/CodaBool/r2-to-vtt]
├── backup:latest (custom image, pushed weekly) [https://github.com/CodaBool/container-s3-cron-backup]
├── rss/
│   ├── upvote:latest
│   ├── rsspuppet:latest
│   ├── rsshub:chromium-bundled
│   ├── rssbridge:latest
│   ├── rss_db:18 [https://miniflux.app/docs/docker.html#docker-compose]
│   ├── rss:latest (custom image, pushed weekly) [https://github.com/CodaBool/miniflux]
│   ├── nitter:latest
│   ├── nitter-redis:6-alpine [https://github.com/zedeus/nitter/blob/master/docker-compose.yml]
│   ├── changedetect:latest
│   └── browserless:latest
├── immich/
│   ├── immich:release
│   ├── immich_ml:release
│   ├── immich_postgres:14-vectorchord0.4.3-pgvectors0.2.0 [https://github.com/immich-app/immich/blob/main/docker/docker-compose.yml]
│   └── immich_redis:9 [https://github.com/immich-app/immich/blob/main/docker/docker-compose.yml]
└── ai/
    ├── librechat:latest
    ├── meili:v1.12.3 [https://github.com/danny-avila/LibreChat/blob/main/deploy-compose.yml]
    ├── mongo:latest
    ├── ollama:rocm
    ├── rag:latest
    └── vectordb:latest
```
