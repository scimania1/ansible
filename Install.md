## Step 1: Partitioning

1. clear the disk and remove all the partitions
2. make partitions of the following sizes and labels
	- Root: 50G (ext4 linux)
	- Boot: 1G (efi)
	- Swap: 8G (swap)
	- Home: remaining (ext4 linux)
3. format these partitions and create the partition tables
4. Then mount the partitions like so:
	- Root: /mnt (`mount /dev/sdx /mnt`)
	- Boot: /mnt/boot (`mount --mkdir /dev/sdx /mnt/boot`)
	- Home: /mnt/home (`mount --mkdir /dev/sdx /mnt/home`)
	- Swap: `swapon /mnt/sdx`

## Step 2: Mirrors

1. Create a backup of the mirrors file `cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup`.
2. Install the `reflector` package.
3. Use the following command: `reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist`

## Step 3: Pacstrap it in

1. Run the command: `pacstrap -K /mnt base linux linux-firmware linux-headers base-devel git vim`
2. `genfstab -U /mnt >> /mnt/etc/fstab`
3. `arch-chroot /mnt`

## Step 4: Pre-Boot Steps

- Some general utitilites to install:
	- `networkmanager`
	- `wpa_supplicant`
	- `wireless_tools`
	- `netctl`
	- `dialog`
	- `wifi-menu`
	- enable `networkmanager.service`

1. Setup the locale: 
	- edit the `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8`
	- Run `locale-gen`
	- `echo "LANG=en_US.UTF-8" > /etc/locale.conf`
	- `export LANG=en_US.UTF-8`
2. Timezone: 
	- `ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime`
	- `hwclock --systohc`
3. Create a hostname: `echo "blackbox" > /etc/hostname`
4. Enable trim for ssd: `systemctl enable fstrim.timer`
5. Uncomment the `multilib` part from `/etc/pacman.conf`
6. Create a root password: `passwd`
7. Create a user: `useradd -m -g users -G wheel,storage,power -s /bin/bash scimania`
8. Create a password for the user: `passwd scimania`
9. Run `visudo` and remove the `#` in front of `%wheel`. At the bottom of the file, add the following `Defaults rootpw`

## Step 5: Installing the boot loader (GRUB)

1. `pacman -S grub efibootmgr dosfstools os-prober mtools`
2. Then run `grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB --recheck`
3. For english error messages:
	- `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`
4. Install the `intel-microcode`: `pacman -S intel-ucode amd-ucode`
5. unblock wifi and bluetooth: `rfkill unblock wlan` and `rfkill unblock bluetooth`
6. Install `dhcpcd`
7. `systemctl enable dhcpcd@${ip link output}.service`
8. Run `grub-mkconfig -o /boot/grub/grub.cfg` after step 6

## Step 6: Installing NVIDIA drivers

- `pacman -S nvidia nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings`
- Edit the `/etc/mkinitcpio.conf`
	- `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
- Edit the `/etc/default/grub` file:
	- `GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 quiet splash"`
- Create a pacman hook:
	```
	[Trigger]
	Operation=Install
	Operation=Upgrade
	Operation=Remove
	Type=Package
	Target=nvidia
	Target=linux
	
	[Action]
	Depends=mkinitcpio
	When=PostTransaction
	Exec=/usr/bin/mkinitcpio -P
	```

## Post Installation

- **After Installation**, if the wifi does not work run wifi-menu, else refer to [Arch wiki](https://wiki.archlinux.org/title/Network_configuration/Wireless)
- also run `nvidia-xconfig` after installation
- run the ansible script
