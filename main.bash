#!/bin/bash

# Создаём файл с текущей датой в имени
OUTPUT_FILE="system_info_$(date +%Y%m%d_%H%M).txt"


while true; do
    if ls -l | grep -q "$OUTPUT_FILE"; then
        echo "Файл с текущей датой уже существует."
        OUTPUT_FILE="system_info_$(date +%Y%m%d_%H%M%S).txt"
    fi
    echo "Сбор информации о системе..." > "$OUTPUT_FILE"
    echo "Дата: $(date)" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"

    echo -e "путь где ты находишься: $(pwd)" >> "$OUTPUT_FILE"
    echo -e "текущий пользователь: $(whoami)" >> "$OUTPUT_FILE"
    echo -e "текущий терминал: $(tty)" >> "$OUTPUT_FILE"
    echo -e "текущий IP: $(hostname -I)" >> "$OUTPUT_FILE"
    echo -e "текущий hostname: $(hostname)" >> "$OUTPUT_FILE"
    echo -e "текущий uptime: $(uptime -p)" >> "$OUTPUT_FILE"
    echo -e "текущий uptime: $(uptime -p)" >> "$OUTPUT_FILE"

    echo -e "\n=== Информация о системе ===" >> "$OUTPUT_FILE"
    uname -a >> "$OUTPUT_FILE"

    echo -e "\n=== Процессор ===" >> "$OUTPUT_FILE"
    lscpu | grep -E "Model name|CPU\(s\)|Thread|Core" >> "$OUTPUT_FILE"

    echo -e "\n=== Память ===" >> "$OUTPUT_FILE"
    free -h >> "$OUTPUT_FILE"

    echo -e "\n=== Использование дисков ===" >> "$OUTPUT_FILE"
    df -h >> "$OUTPUT_FILE"

    echo -e "\n=== Топ 10 процессов по CPU ===" >> "$OUTPUT_FILE"
    ps aux --sort=-%cpu | head -11 >> "$OUTPUT_FILE"

    echo -e "\n=== Сетевые интерфейсы ===" >> "$OUTPUT_FILE"
    ip a >> "$OUTPUT_FILE"

    if command -v sensors &> /dev/null; then
    echo -e "\n=== Температура ===" >> "$OUTPUT_FILE"
    sensors >> "$OUTPUT_FILE"
    fi

    echo -e "\n=== Версия системы ===" >> "$OUTPUT_FILE"
    if [ -f /etc/os-release ]; then
    cat /etc/os-release >> "$OUTPUT_FILE"
    fi

    echo "----------------------------------------" >> "$OUTPUT_FILE"
    echo "Информация собрана в файл: $OUTPUT_FILE"
    sleep 10

done