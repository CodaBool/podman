# Podman Self-Host
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
When a `.container` file is placed into `/.config/containers/systemd` it automatically becomes a systemd service 🪄

## Structure
> I have a RAID 1 HDD with this structure
```
└── mnt/
    ├── volumes/
    │   ├── container_name
    │   └── .container_name.env
    ├── media/
    │   ├── movies
    │   └── tv
    └── sync
```

## Security
- [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks) provided by the tunnel container
- CloudFlare WAF blocking non-US traffic

## Automatic Updates
1. add `AutoUpdate=registry` to your `.Container`
2. `sudo systemctl enable --now podman-auto-update.timer`

## Automatic run on boot
`loginctl enable-linger $USER`

## Validation
`/usr/libexec/podman/quadlet --user --dryrun`

## Expose Podman socket
> written to `/run/user/1000/podman/podman.sock`

`systemctl --user enable --now podman.socket`
