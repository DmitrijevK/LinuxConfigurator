menu()
{
	clear
	Info
	log_t "Авто Установщик Полезных программ для линукса"
	Info "- 1  -  Cryptography"
	Info "- 2  -  Wallet"
	Info "- 3  -  Telegram"
        Info "- 4  -  Browsers"
	Info "- 0  -  Выход"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню:" case
	case $case in
		1) cryptors;;   
		2) wallet;;
		3) telegram;;
                4) browser;;
		0) exit;;
	esac
}
menu

browser()
{
	clear
	Info
	log_t "Установщик Браузеров"
  Info "- 1  -  Dolphin Anty"
  Info "- 2  -  Octo Browser"
  Info "- 3  -  Tor Browser"
	Info "- 0  -  Выход"
	log_s
	Info
read -p "Пожалуйста, введите пункт меню:" case
case $case in
	1) dolphin;;   
	2) octo_browser;;
	3) torbrowser;;
    0) exit;;
esac

}
browser

torbrowser()
{
sudo apt install tor torbrowser-launcher
}

cryptors()
{
	clear
	Info
	log_t "Крипторы | Советую VeraCrypt"
  Info "- 1  -  Vera Crypt"
  Info "- 2  -  True Crypt"
	Info "- 0  -  Выход"
	log_s
	Info
read -p "Пожалуйста, введите пункт меню:" case
case $case in
	1) veracrypt;;   
	2) truecrypt;;
    0) exit;;
esac

}
cryptors

wallet()
{
#electrum
sudo apt install python3-pip python3-setuptools python3-pyqt5 libsecp256k1-dev

#Litecoincore

}
wallet
telegram()
{
sudo
sudo apt install snapd
sudo systemctl  enable snapd.service
sudo systemctl start snapd.service
sudo snap install telegram-desktop
snap run telegram-desktop
sudo start snapd.apparmor service
}
telegram
