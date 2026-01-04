# Podman Self-Host
<a href="https://www.youtube.com/watch?v=2H5lqPRPNhA">
  <img src="https://stargazer.vercel.app/pom.gif" style="height:70px;">
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
    ├── volumes/
    │   ├── container_name
    │   └── .container_name.env
    ├── media/
    │   ├── movies
    |   ├── tv
    │   └── downloads
    └── sync
```

## Security
- [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks) provided by the tunnel container
- CloudFlare WAF blocking non-US traffic

## Automatic Updates
> effectively runs `podman auto-update` daily and then `podman image prune -f`. If the container fails to start after auto-update, then it will automatically be rolled back

1. add `AutoUpdate=registry` to your `.Container`
2. `sudo systemctl enable --now podman-auto-update.timer` (for root)
3. `systemctl --user enable --now podman-auto-update.timer` (for rootless)

## Automatic run on boot
> by default services will not run unless the user is logged in. This allows the service to run anytime

`loginctl enable-linger $USER`

## Quadlet Validation
`/usr/libexec/podman/quadlet --user --dryrun`

## Expose Podman socket
> written to `/run/user/1000/podman/podman.sock`

`systemctl --user enable --now podman.socket`

## Stats
- GPU (AMD): `podman run --rm -it --privileged docker.io/joonas/radeontop`
- CPU & Memory: `podman stats CONTAINER_NAME`

## Permission Debug
`ausearch -i -m avc`, shows what SELinux policy is blocking. If empty then your problem is not SELinux related.

You can temporarily run a container with SELinux disabled `--security-opt=label=disable` or `PodmanArgs=--privileged`

`ps` outside the container can show what UID the container runs as, then confirm that this user is able to access your files.

You can also use `strace -p <pid> --decode-fds=all` on the process to observe exactly which system call is returning an error to the application.


# Services

```md
├── uptime:latest
├── tunnel:latest
├── tools:latest
├── pastebin:latest
├── jellyfin:latest
├── foundry_2:latest
├── foundry_1:13
├── backup:latest (custom image, pushed weekly) [https://github.com/CodaBool/container-s3-cron-backup]
├── rss/
│   ├── upvote:latest
│   ├── rsspuppet:latest
│   ├── rsshub:chromium-bundled
│   ├── rssbridge:latest
│   ├── rss_db:18 [last checked 2025-12]
│   ├── rss:latest
│   ├── nitter:latest
│   ├── nitter-redis:6-alpine [last checked 2025-12]
│   ├── changedetect:latest
│   └── browserless:latest
├── immich/
│   ├── immich:release
│   ├── immich_ml:release
│   ├── immich_postgres:14-vectorchord0.4.3-pgvectors0.2.0 [last checked 2025-12]
│   └── immich_redis:9 [last checked 2025-12]
└── ai/
    ├── librechat:latest
    ├── meili:v1.12.3 [last checked 2025-12]
    ├── mongo:latest
    ├── ollama:rocm
    ├── rag:latest
    └── vectordb:latest
```
