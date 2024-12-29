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


## How does it work
When a `.container` file is placed into `/.config/containers/systemd` it automatically becomes a systemd service 🪄

## Structure
> I have a RAID 1 HDD with this structure
```
└── mnt/
    ├── volumes/
    │   ├── containerName
    │   └── .containerName.env
    ├── media/
    │   ├── movies
    │   └── tv
    └── sync
```

# Access
For extra security I use Cloudflare Tunnels as well as a WAF

# [Tips](https://podman.io/docs)
## Automatic Updates
1. add `AutoUpdate=registry` to your `.Container`
2. `sudo systemctl enable --now podman-auto-update.timer`

## Automatic run on boot
`loginctl enable-linger 1000`

## Container Validation
`/usr/libexec/podman/quadlet --user --dryrun`

## Expose Podman socket
`systemctl enable --now podman.socket`
