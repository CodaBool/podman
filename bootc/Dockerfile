FROM quay.io/fedora/fedora-bootc:41




# TODO: test if this is really needed to process NVENC encode
# ADD https://repo.jellyfin.org/files/ffmpeg/linux/latest-7.x/amd64/jellyfin-ffmpeg_7.0.2-8_portable_linux64-gpl.tar.xz /tmp
# RUN mkdir /tmp/jellyfin-ffmpeg
# RUN tar -xvf /tmp/jellyfin-ffmpeg_7.0.2-8_portable_linux64-gpl.tar.xz -C /tmp/jellyfin-ffmpeg
# RUN mv /tmp/jellyfin-ffmpeg /usr/lib




# RUN dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#RUN dnf config-manager setopt fedora-cisco-openh264.enabled=1
# RUN dnf update -y && dnf install -y git akmod-nvidia xorg-x11-drv-nvidia-cuda && dnf clean all


# I'm buying amd nvidia driver support sucks

RUN dnf update -y && dnf install -y git && dnf clean all