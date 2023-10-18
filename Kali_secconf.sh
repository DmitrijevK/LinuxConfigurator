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
sudo openvpn --config 
}
