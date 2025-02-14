[Container]
ContainerName=vectordb
Image=docker.io/ankane/pgvector
UserNS=keep-id:uid=1000,gid=1000

Environment=POSTGRES_DB=mydatabase
Environment=POSTGRES_USER=myuser
Environment=POSTGRES_PASSWORD=mypassword

Volume=/mnt/volumes/vectordb:/var/lib/postgresql/data:Z
#Network=container:gluetun

# auto update
AutoUpdate=registry

# selector for backup container to stop with
Label=docker-volume-backup.stop-during-backup=true

[Service]

# allow time for a new image to download
TimeoutStartSec=900
Restart=always

[Install]

# automatic startup
WantedBy=default.target
