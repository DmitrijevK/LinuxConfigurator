#!/bin/bash

show_menu() {
    echo "Выберите функцию:"
    echo "1. Настроить Proxy"
    echo "2. Настроить VPN"
    echo "3. Настроить операционную систему"
    echo "4. Выйти"
}

show_vpn_menu() {
    echo "Выберите функцию:"
    echo "1. Поставить статичный VPN"
    echo "2. Поставить динамичный VPN"
}

ProxyConf() {
    PROXY_LIST_FILE="proxylist.txt"
    if [ ! -f $PROXY_LIST_FILE ]; then
        echo "Файл $PROXY_LIST_FILE не найден. Пожалуйста, убедитесь, что он существует."
        return
    fi

    CONFIG_FILE="/etc/proxychains4.conf"
    if [ ! -f $CONFIG_FILE ]; then
        echo "Файл $CONFIG_FILE не найден. Пожалуйста, убедитесь, что proxychains4 установлен."
        return
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

    while true; do
        while read -r proxy; do
            sudo sed -i "s/^socks4.*/$proxy/" $CONFIG_FILE
            sleep $SWITCH_INTERVAL
        done < $PROXY_LIST_FILE
    done
}

setup_static_vpn() {
    echo "Введите путь к файлу .ovpn для статичного VPN:"
    read ovpn_config_path
    sudo apt-get update && sudo apt-get upgrade && sudo apt-get install openvpn -y
    sudo openvpn --config $ovpn_config_path
    echo "Установка и настройка статичного VPN завершена."
}

setup_dynamic_vpn() {
    echo "Введите путь к файлу с подключениями к VPN:"
    read vpn_connection_file
    echo "Введите интервал переключения в секундах:"
    read switch_interval
    sudo apt-get update && sudo apt-get upgrade && sudo apt-get install openvpn -y
    while true; do
        while IFS=, read -r vpn_config; do
            sudo openvpn --config $vpn_config
            sleep $switch_interval
        done < $vpn_connection_file
    done
}

OperSystem() {
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
        return
    fi
    if grep -q "^$NEW_DNS_SERVER" $CONFIG_FILE; then
        echo "Строка '$NEW_DNS_SERVER' уже существует в файле."
        return
    fi
    echo $NEW_DNS_SERVER | sudo tee -a $CONFIG_FILE > /dev/null
    echo "Строка '$NEW_DNS_SERVER' успешно добавлена в файл $dCONFIG_FILE."
    echo "Настройка операционной системы завершена."
}

while true; do
    show_menu
    read choice
    case $choice in
    1)
        ProxyConf
        ;;
    2)
        while true; do
            show_vpn_menu
            read vpn_choice
            case $vpn_choice in
            1)
                setup_static_vpn
                break
                ;;
            2)
                setup_dynamic_vpn
                break
                ;;
            *)
                echo "Неверный выбор. Попробуйте еще раз."
                ;;
            esac
        done
        ;;
    3)
        OperSystem
        ;;
    4)
        echo "Выход из скрипта"
        exit 0
        ;;
    *)
        echo "Неверный выбор. Попробуйте еще раз."
        ;;
    esac
done
