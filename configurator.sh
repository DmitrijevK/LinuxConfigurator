#!/bin/bash

Infon() {
	printf "\033[1;32m$@\033[0m"
}
Info()
{
	Infon "$@\n"
}
Error()
{
	printf "\033[1;31m$@\033[0m\n"
}
Error_n()
{
	Error "$@"
}
Error_s()
{
	Error "============================================"
}
log_s()
{
	Info "============================================= "
}
log_n()
{
	Info " $@"
}
log_t()
{
	log_s
	Info "$@"
	log_s
}

menu()
{
	clear
	Info
	log_t "Конфигурационный скрипт Linux Server(a) By Spike"
	Info "- 1  -  VDS"
	Info "- 2  -  Настройка FTP "
	Info "- 3  -  Конфигурация FireWall"
    Info "- 4  -  Конфигурация NAS из обычной Linux машины"
	Info "- 0  -  Выход"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню:" case
	case $case in
		1) vds;;   
		2) ftp_users;;;;
		3) FireWall;;
        4) nas_konfig;;
		0) exit;;
	esac
}
menu

vds()
{
	clear
	Info
	log_t "VDS настройки и конфигурации"
	Info "- 1  -  VDS"
	Info "- 2  -  Настройка FTP "
	Info "- 3  -  Конфигурация FireWall"
	Info "- 0  -  Выход"
	log_s
	Info
read -p "Пожалуйста, введите пункт меню:" case
case $case in
	1) vds_base_install;;   
	2) ftp_users;;
	3) FireWall;;
    0) exit;;
esac

}
vds

vds_base_install()
{
	apt-get update
	apt-get install -y ca-certificates
	apt-get install -y apt-utils
	apt-get install -y pwgen
	apt-get install -y wget
	apt-get install -y sudo
	apt-get install -y unzip
	apt-get install -y pure-ftpd
	apt-get install -y dialog
	MYPASS=$(pwgen -cns -1 20)
	MYPASS2=$(pwgen -cns -1 20)
	OS=$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g' | grep Ubuntu)
		if [ "$OS" = "Debian8" ]; then
		log_t "• Добавляем репозиторий •"
		echo "deb http://ftp.ru.debian.org/debian/ jessie main" > /etc/apt/sources.list
		echo "deb-src http://ftp.ru.debian.org/debian/ jessie main" >> /etc/apt/sources.list
		echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
		echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
		echo "deb http://ftp.ru.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
		echo "deb-src http://ftp.ru.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
		log_t "• Обновляем пакеты •"
		apt-get update
	fi
	if [ "$OS" = "" ]; then
		log_t "Add repository"
		echo "deb http://packages.dotdeb.org wheezy-php56 all">"/etc/apt/sources.list.d/dotdeb.list"
		echo "deb-src http://packages.dotdeb.org wheezy-php56 all">>"/etc/apt/sources.list.d/dotdeb.list"
		wget http://www.dotdeb.org/dotdeb.gpg
		apt-key add dotdeb.gpg
		rm dotdeb.gpg
		log_t "Update"
		apt-get update
	fi
	log_t "Upgrade"
	apt-get upgrade -y
	echo mysql-server mysql-server/root_password select "$MYPASS" | debconf-set-selections
	echo mysql-server mysql-server/root_password_again select "$MYPASS" | debconf-set-selections
	log_t "Install packages"
	apt-get install -y apache2 php5 php5-dev cron unzip sudo php5-curl php5-memcache php5-json memcached mysql-server libapache2-mod-php5	
	if [ "$OS" = "" ]; then
		apt-get install -y php5-ssh2
	else
		apt-get install -y  libssh2-php
	fi
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
	apt-get install -y phpmyadmin
	echo mysql-apt-config mysql-apt-config/select-server select mysql-5.6 | debconf-set-selections
	echo mysql-apt-config mysql-apt-config/select-product select Ok | debconf-set-selections
	wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
	export DEBIAN_FRONTEND=noninteractive
	dpkg -i mysql-apt-config_0.8.7-1_all.deb 
    apt-get update
	apt-get --yes --force-yes install mysql-server
	sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables
	service mysql restart
	rm mysql-apt-config_0.8.7-1_all.deb
	cd ~
	sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables
	service mysql restart
	a2enmod rewrite
	a2enmod php5
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php5/apache2/php.ini	 
	echo "Europe/Moscow" > /etc/timezone
	dpkg-reconfigure tzdata -f noninteractive
	sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/cli/php.ini
	sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/apache2/php.ini
	sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
	(crontab -l ; echo "*/1 * * * * sync; echo 1 > /proc/sys/vm/drop_caches") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
	service apache2 restart
	groupadd ftpusers
	echo "yes" > /etc/pure-ftpd/conf/CreateHomeDir
	echo "yes" > /etc/pure-ftpd/conf/NoAnonymous
	echo "yes" > /etc/pure-ftpd/conf/ChrootEveryone
	echo "yes" > /etc/pure-ftpd/conf/VerboseLog
	echo "yes" > /etc/pure-ftpd/conf/IPV4Only
	echo "100" > /etc/pure-ftpd/conf/MaxClientsNumber
	echo "8" > /etc/pure-ftpd/conf/MaxClientsPerIP
	echo "no" > /etc/pure-ftpd/conf/DisplayDotFiles 
	echo "15" > /etc/pure-ftpd/conf/MaxIdleTime
	echo "16" > /etc/pure-ftpd/conf/MaxLoad
	echo "50000 50300" > /etc/pure-ftpd/conf/PassivePortRange
	rm /etc/pure-ftpd/conf/PAMAuthentication /etc/pure-ftpd/auth/70pam 
	ln -s ../conf/PureDB /etc/pure-ftpd/auth/45puredb
	pure-pw mkdb
	/etc/init.d/pure-ftpd restart
	clear
	Info
	log_t "Настройка VDS Успешно Завершена. "
	Info "- - Данные для входа в phpMyAdmin | Логин: root Пароль: $MYPASS"
	Info "- - Теперь Вы Можете Заливать Файлы Движка, CMS На сервер Через SSH Доступ"
	Info "- - Файлы для сайтов Сюда /var/www/html"
	Info "- - Распаковка архива командой unzip"
	exit


}
vds_base_install

ftp_users()
{

	clear
	Info
	log_t "Центр управление FTP"
	Info "- 1  -  Сделать FTP Аккаунт"
	Info "- 2  -  Сменить Пароль FTP Аккаунта"
	Info "- 3  -  Удалить FTP Пользователя"
	Info "- 0  -  К Управлению Сервером"
	log_s
	Info
	read -p "Пожалуйста, выберите пункт меню:" case
	case $case in
		1) 
		read -p "Пожалуйста, Введите Логин для FTP Аккаунта:" login
		useradd -g ftpusers -d /var/www/ -s /sbin/nologin ftpusers
		chown -R ftpusers:ftpusers /var/www/*
		log_t "Пожалуйста, Введите Логин для FTP Аккаунта"
		pure-pw useradd $login -u ftpusers -d /var/www/
		pure-pw mkdb
		log_n "FTP Аккаунт Создан"
		/etc/init.d/pure-ftpd restart
		menu_f1
		;;
		2) 		
		read -p "${CYAN}Пожалуйста, Введите Логин для FTP Аккаунта:" login
		pure-pw passwd $login
		pure-pw mkdb
		log_t " Ваш Пароль Для FTP Аккаунта Успешно Изменён"
		/etc/init.d/pure-ftpd restart
		ftp_users
		;;
		3) 
		read -p "${CYAN}Пожалуйста, Введите Логин для FTP Аккаунта: " login
		pure-pw userdel $login
		pure-pw mkdb
		log_t " FTP Аккаунт Успешно Удалён"
		/etc/init.d/pure-ftpd restart
		ftp_users
		;;
		0) menu;;
		
	esac
}
ftp_users


menu_f1()
{
	clear
	Info
	Info "- - Вы успешно создали FTP Аккаунт  "
	exit
}

menu_d1()
{
	clear
	Info
	Info "- - Вы успешно создали Домен $DOMAIN "
	exit
}

FireWall()
{
	clear
	Info
	log_t "Конфигурация FireWall"
	Info "- 1  -  Lite mode"
	Info "- 2  -  Average mode"
	Info "- 3  -  Hard mode"
    Info "- 3  -  Удалить FireWall"
	Info "- 0  -  Выход"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню:" case
	case $case in
		1) lite_firewall;;   
		2) average_firewall;;;;
		3) hard_firewall;;
        4) delite_firewall;;
		0) exit;;
	esac


}
FireWall

lite_firewall()
{
	clear
    Info
	log_t "Конфигурация FireWall Lite mode"
    Info "- Введите пароль от OS"
    log_s
    Info
    read yourospassword
    sudo su $yourospassword
    echo "закрывам INPUT, FORWARD..."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    echo "закрывам INPUT, FORWARD"
    echo "Разрешаем определенные пакеты"
    iptables -t filter -A FORWARD -m state - -state ESTABLISHED,RELATED -j ACCEPT
    iptables -t filter -A INPUT -i enp0s3  -m state - -state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT

}
lite_firewall
