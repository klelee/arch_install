#!/bin/bash

function set_var {
	read -r -p "Enter the username: " uname
	read -r -p "Enter the hostname that is your system's name: " hname
	echo -e "Choose a Desktop Environment to install: \n"
	echo -e "1. GNOME \n2. Deepin \n3. KDE \n4. i3wm \n5. null"
	read -r -p "DE: " desktop
}

function set_mirrorlist {
	systemctl stop reflector
	echo "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
	echo "set mirrorlist ok!"
	sleep 1
}

function set_time {
	echo "setting time ..."
	timedatectl set-ntp true
	echo "set time ok!"
	sleep 1
}

function partition {
	echo "Please complete the partition manually !"
	echo "cfdisk will be used partitioning! Following partition have to set! "
	echo "1. You need to set a [EFI] partition with 300M disk space! "
	echo "2. And need to set a [swap] partition with 16G at least! sure, you can no swap patition"
	echo "3. And other partition is [/] . "
	lsblk -f
	read -r -p "which disk do you want to install archlinux on? (example /dev/sda) " disk
	cfdisk $disk

	lsblk -f
	read -r -p "Would you like to add other patition sach as home and data patition to other disk? [y/n]" is_setdata
	case "$is_setdata" in
		[yY][eE][sS]|[yY])
			echo "4. If you want to add home(data) partition to other disk. "
			read -r -p "Please enter your diskname(example /dev/sdb) " ddisk
			cfdisk $ddisk
			;;
		*)
			;;
	esac
}

function fs_format {

	lsblk -f
	read -r -p "Which is your root partition(example /dev/sda3)? " rootp
	mkfs.xfs -f $rootp
	mount $rootp /mnt
	mkdir -p /mnt/boot
	mkdir -p /mnt/home

	lsblk -f
	read -r -p "Do you have swap patition? [y/n]" is_haveswap
	case "$is_haveswap" in
		[yY][eE][sS]|[yY])
			read -r -p "Which is your swap partition(example /dev/sda2)? " swapp
			mkswap $swapp
			swapon $swapp
			;;
		*)
			;;
	esac

	lsblk -f
	read -r -p "Which is your EFI partition(example /dev/sda1)? " EFIp
	mkfs.vfat $EFIp
	mount $EFIp /mnt/boot

	lsblk -f
	read -r -p "Do you have home(data) patition? [y/n]" is_havedata
	case "$is_havedata" in
		[yY][eE][sS]|[yY])
			read -r -p "Which is your home(data) patition(example /dev/sdb1)" homep
			mkfs.xfs -f $homep
			mount $homep /mnt/home
			;;
		*)
			;;
	esac

}

function base_install {
	echo "Starting installation of packages in selected root drive..."
	sleep 1
	pacman -Sy --noconfirm archlinux-keyring
	pacstrap /mnt base diffutils linux linux-firmware logrotate usbutils which base-devel networkmanager sudo bash-completion git vim exfat-utils ntfs-3g grub os-prober efibootmgr pacman-contrib intel-ucode openssh
	genfstab -U /mnt >> /mnt/etc/fstab
}

function install_grub {
	echo -e "Installing GRUB.."
	arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Arch && grub-mkconfig -o /boot/grub/grub.cfg && exit"
}

function archroot {
	echo -e "Setting up Region and Language\n"
	arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc && sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && locale-gen && echo 'LANG=en_US.UTF-8' > /etc/locale.conf && exit"

	echo -e "Setting up Hostname\n"
	arch-chroot /mnt /bin/bash -c "echo $hname > /etc/hostname && echo 127.0.0.1	$hname > /etc/hosts && echo ::1	$hname >> /etc/hosts && echo 127.0.1.1	$hname.localdomain	$hname >> /etc/hosts && exit"

	echo "Set Root password"
	arch-chroot /mnt /bin/bash -c "passwd && useradd --create-home $uname && echo 'set user password' && passwd $uname && groupadd sudo && gpasswd -a $uname sudo && EDITOR=vim visudo && exit"

	echo -e "Set user sudo..."
	arch-chroot /mnt /bin/bash -c "usermod -aG wheel,users,storage,power,lp,adm,optical $uname && exit"

	echo -e "enabling openssh services...\n"
	arch-chroot /mnt /bin/bash -c "systemctl enable sshd && exit"

	echo -e "enabling services...\n"
	arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager && exit"

	echo -e "enabling paccache timer...\n"
	arch-chroot /mnt /bin/bash -c "systemctl enable paccache.timer && exit"

	echo -e "Editing configuration files...\n"
	# Enabling multilib in pacman
	arch-chroot /mnt /bin/bash -c "sed -i '93s/#\[/\[/' /etc/pacman.conf && sed -i '94s/#I/I/' /etc/pacman.conf && pacman -Syu && sleep 1 && exit"
}

function install_gnome {
	pacstrap /mnt gnome gnome-tweaks papirus-icon-theme
	arch-chroot /mnt /bin/bash -c "systemctl enable gdm && exit"
	# Editing gdm's config for disabling Wayland as it does not play nicely with Nvidia
	arch-chroot /mnt /bin/bash -c "sed -i 's/#W/W/' /etc/gdm/custom.conf && exit"
}

function install_deepin {
	pacstrap /mnt deepin lightdm gedit
	arch-chroot /mnt /bin/bash -c "systemctl enable lightdm && exit"
}

function install_kde {
	pacstrap /mnt xorg plasma sddm
	arch-chroot /mnt /bin/bash -c "systemctl enable sddm && exit"
	pacstrap /mnt ark dolphin gwenview kate konsole ksystemlog print-manager spectacle
}

function install_i3wm {
	pacstrap /mnt xorg xorg-xinit i3-gaps i3blocks i3lock i3status dmenu rofi feh thunar xfce4-terminal xfce4-power-manager compton network-manager-applet
	arch-chroot /mnt /bin/bash -c "cp /etc/X11/xinit/xinitrc /home/${uname}/.xinitrc && exit"
	arch-chroot /mnt /bin/bash -c "sed -i '$d' /home/${uname}/.xinitrc && sed -i '$d' /home/${uname}/.xinitrc && sed -i '$d' /home/${uname}/.xinitrc && sed -i '$d' /home/${uname}/.xinitrc && sed -i '$d' /home/${uname}/.xinitrc && exit "
	arch-chroot /mnt /bin/bash -c "echo 'exec i3' >> /home/${uname}/.xinitrc && exit "
}

function graphics {
	pacstrap /mnt ttf-dejavu ttf-droid ttf-hack ttf-font-awesome otf-font-awesome ttf-lato ttf-liberation ttf-linux-libertine ttf-opensans ttf-roboto ttf-ubuntu-font-family \
	ttf-hannom noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk adobe-source-code-pro-fonts adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-han-sans-cn-fonts \
	adobe-source-han-sans-hk-fonts adobe-source-han-sans-tw-fonts adobe-source-han-serif-cn-fonts wqy-zenhei wqy-microhei

	arch-chroot /mnt /bin/bash -c 'sed -i s/#export/export/ /etc/profile.d/freetype2.sh' 
}

function de {

	case "$desktop" in
		1)
			install_gnome
			;;
		2)
			install_deepin
			;;
		3)
			install_kde
			;;
		4)
			install_i3wm
			;;
		*)
			;;
	esac
}

function installation {
	set_var
	set_mirrorlist
	set_time
	partition
	fs_format
	base_install
	install_grub
	archroot
	de
	graphics
	echo "Installation complete. Reboot you lazy bastard."
}

function main {
	echo "arch yyds!"
	setfont ter-118n
	installation
}

main
