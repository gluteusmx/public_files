text
lang en_US.UTF-8
keyboard us
timezone Europe/Moscow
selinux --enforcing
firewall --enabled --service=mdns,ssh
services --enabled=sshd,NetworkManager,chronyd
network --bootproto=dhcp --device=link --activate
rootpw locked 
bootloader --location=mbr --append="rhgb quiet" --timeout=3 --default=fedora
zerombr
clearpart --linux
part / --size 5120 --fstype ext4
network --bootproto=dhcp --device=link --activate
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
shutdown




%packages
fedora-release-server

@core
@standard
@hardware-support
@server-product
-initial-setup-gui
-generic-release*

kernel
kernel-modules
kernel-modules-extra

# This was added a while ago, I think it falls into the category of
# "Diagnosis/recovery tool useful from a Live OS image".  Leaving this untouched
# for now.
memtest86+


# The point of a live image is to install
anaconda
anaconda-install-env-deps
anaconda-live
@anaconda-tools

kernel
# remove this in %post
dracut-config-generic
-dracut-config-rescue

chrony
initial-setup

# make sure all the locales are available for inital-setup and anaconda to work
glibc-all-langpacks

# Need aajohan-comfortaa-fonts for the SVG rnotes images
aajohan-comfortaa-fonts

# Without this, initramfs generation during live image creation fails: #1242586
dracut-live
syslinux 

# anaconda needs the locales available to run for different locales
glibc-all-langpacks

# no longer in @core since 2018-10, but needed for livesys script
initscripts
chkconfig

#packages needed for setup Lab-stand
ansible
git

%end

%post

#adding user linux-adm with empty password
/usr/sbin/useradd -c "linux-adm" -m -p $y$j9T$eD.VixkneDTCaY7gqizMw.$77f9OngC2Pjnxg4oiB6hxRXA5q1dwpzjogxrCuzPkj7 linux-adm
/usr/bin/passwd -u linux-adm
/usr/sbin/usermod -aG wheel linux-adm > /dev/null

cd /home/linux-adm/
cat << EOF > install.sh
#!/bin/bash
#This script will start anaconda installation with server kickstart

liveinst --ks inst.ks=https://raw.githubusercontent.com/gluteusmx/public_files/main/serv.ks

# --kickstart /local/path
EOF

chmod +x install.sh
chown linux-adm:linux-adm -R ./

#get playbooks for setup Lab


#######TEMPLATED FROM SPIN_KICKSTARTS
#
# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

# Find the architecture we are on
arch=$(uname -m)

releasever=$(rpm --eval '%{fedora}')
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-primary
echo "Packages within this disk image"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*



%end