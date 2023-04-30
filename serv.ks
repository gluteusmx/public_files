text
lang en_US.UTF-8
keyboard us
timezone Europe/Moscow
selinux --enforcing
firewall --enabled --service=mdns,ssh
services --enabled=sshd,NetworkManager,chronyd
network --bootproto=dhcp --device=link --activate
rootpw --lock --iscrypted locked
shutdown

bootloader --timeout=1

zerombr
clearpart --all --initlabel --disklabel=msdos

# make sure that initial-setup runs and lets us do all the configuration bits
firstboot --reconfig

repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

services --enabled=sshd,NetworkManager,chronyd,initial-setup

autopart --noswap

%packages
fedora-release-server
# install the default groups for the server environment since installing the environment is not working
@server-product
@standard
@core
@headless-management
@hardware-support 
@networkmanager-submodules

@container-management
@domain-client
@guest-agents
@server-hardware-support
-initial-setup-gui
-generic-release*
%end

%post

# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

%end

%packages
@core
@standard
@hardware-support

kernel
# remove this in %post
dracut-config-generic
-dracut-config-rescue

chrony
initial-setup
# Intel wireless firmware assumed never of use for disk images
-iwl*
-ipw*
-usb_modeswitch
-generic-release*

# make sure all the locales are available for inital-setup and anaconda to work
glibc-all-langpacks

%end

%post

# Find the architecture we are on
arch=$(uname -m)


releasever=$(rpm --eval '%{fedora}')
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-primary
echo "Packages within this disk image"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# The enp1s0 interface is a left over from the imagefactory install, clean this up
rm -f /etc/NetworkManager/system-connections/*.nmconnection

dnf -y remove dracut-config-generic

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

%end