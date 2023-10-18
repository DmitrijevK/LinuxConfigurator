#!/bin/bash



ProxyConf()
{
CONFIG_FILE="/etc/proxychains4.conf"
if [ ! -f $CONFIG_FILE ]; then
    echo "Файл $CONFIG_FILE не найден. Пожалуйста, убедитесь, что proxychains4 установлен."
    exit 1
fi
add_comment() {
    local target_pattern="$1"
    sed -i "/$target_pattern/ s/^/#/" $CONFIG_FILE
}
remove_comment() {
    local target_pattern="$1"
    sed -i "/$target_pattern/ s/^#//" $CONFIG_FILE
}
add_comment "strict_chain"
remove_comment "dynamic_chain"
}

OpenVpn()
{
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install openvpn -y
#dorabotat sistemu konfiga
echo "Есть ли у вас конфиг? Y\N"
read oovpnconfigname
sudo openvpn --config $oovpnconfigname
}

OperSystem()
{
#Antimac
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install macchanger -y
echo "Укажите wlan из списка в ipconfig"
read wlanname
sudo ifconfig wlan0 down && sudo macchanger -r $wlanname && sudo ifconfig $wlanname up
echo "МАК сменен"

#AntiDns
echo "Введите ваш DNS SERVER ПО ПРИНЦИПУ: nameserver 8.8.8.8"
read NEW_DNS_SERVER
dCONFIG_FILE="/etc/resolv.conf"
if [ ! -f $dCONFIG_FILE ]; then
    echo "Файл $dCONFIG_FILE не найден. Пожалуйста, убедитесь, что он существует."
    exit 1
fi
if grep -q "^$NEW_DNS_SERVER" $CONFIG_FILE; then
    echo "Строка '$NEW_DNS_SERVER' уже существует в файле."
    exit 0
fi
echo $NEW_DNS_SERVER | sudo tee -a $CONFIG_FILE > /dev/null
echo "Строка '$NEW_DNS_SERVER' успешно добавлена в файл $dCONFIG_FILE."
}


{
# Открываем файл torcc для чтения
with open('/tor-browser/Browser/TorBrowser/Data/Tor/torcc', 'r') as torcc_file:
    torcc_content = torcc_file.read()

# Спрашиваем у пользователя, какие страны необходимо исключить
excluded_countries = input("Введите коды стран для исключения (разделите их запятой, например: BY,RU): ").split(',')

# Генерируем строку для исключения стран
exclude_string = ','.join(excluded_countries)


new_torcc_content = torcc_content + f"ExitNodes {{US}}\nStrictExitNodes 1\nExcludeNodes {exclude_string}\n"

with open('/tor-browser/Browser/TorBrowser/Data/Tor/torcc', 'w') as torcc_file:
    torcc_file.write(new_torcc_content)


}
