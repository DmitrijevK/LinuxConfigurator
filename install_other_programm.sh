menu()
{
	clear
	Info
	log_t "Авто Установщик Полезных программ для линукса"
	Info "- 1  -  Telegram"
	Info "- 2  -  Electrum"
	Info "- 3  -  VeraCrypt"
  Info "- 4  -  Dolphin Anty"
  Info "- 5  -  Octo Browser"
	Info "- 0  -  Выход"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню:" case
	case $case in
		1) telegram;;   
		2) electrum;;
		3) veracrypt;;
    4) nas_konfig;;
		0) exit;;
	esac
}
menu

menu

browser()
{
	clear
	Info
	log_t "VDS настройки и конфигурации"
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
