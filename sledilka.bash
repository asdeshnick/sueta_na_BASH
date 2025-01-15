#!/bin/bash

watch_target() {
    local target="$1"
    local last_modified=""
    local last_snapshot=""
    local last_users=""
    local log_file="sledilka_$(date '+%Y%m%d_%H%M%S').txt"
    
    # Перенаправляем выводы в файл 
    exec 1> >(tee -a "$log_file")
    exec 2>&1

    if ! touch "$log_file" 2>/dev/null; then
        echo "Ошибка: Не могу создать файл логов в текущей директории"
        exit 1
    fi
    
    
    exec 1> >(tee -a "$log_file") 2>&1 || {
        echo "Ошибка: Не удалось настроить перенаправление вывода"
        exit 1
    }
    
    if [ $# -ne 1 ]; then
        echo "Использование: $0 путь/к/файлу_или_папке"
        exit 1
    fi

    # Проверяем цель
    if [ ! -e "$target" ]; then
        echo "Путь $target не существует!"
        exit 1
    fi
    
    # Определяем тип цели (файл или папка)
    if [ -f "$target" ]; then
        echo "Начинаю следить за файлом: $target"
        last_modified=$(stat -f %m "$target" 2>/dev/null || stat -c %Y "$target")
    else
        echo "Начинаю следить за папкой: $target"
        last_snapshot=$(ls -lR "$target" 2>/dev/null)
    fi
    
    echo "Нажмите Ctrl+C для остановки"
    
    while true; do
        if [ -f "$target" ]; then
            # Логика для файла
            current_modified=$(stat -f %m "$target" 2>/dev/null || stat -c %Y "$target")
            current_users=$(lsof "$target" 2>/dev/null | awk 'NR>1 {print $3}' | sort -u | tr '\n' ',' | sed 's/,$//')
            
            if [ "$last_users" != "$current_users" ]; then
                if [ -z "$current_users" ]; then
                    echo "Файл $target сейчас никем не открыт"
                else
                    echo "Файл $target сейчас открыт пользователем(ями): $current_users"
                fi
                last_users=$current_users
            fi
            
            if [ "$last_modified" != "$current_modified" ]; then
                echo "Файл $target был изменен в $(date '+%Y-%m-%d %H:%M:%S')"
                last_modified=$current_modified
            fi
            
            # Проверяем существование файла
            if [ ! -f "$target" ]; then
                echo "Файл $target был удален!"
                exit 1
            fi
        else
            # Логика для папки
            current_snapshot=$(ls -lR "$target" 2>/dev/null)
            current_users=$(lsof "$target"/* 2>/dev/null | awk 'NR>1 {print $3}' | sort -u | tr '\n' ',' | sed 's/,$//')
            
            if [ "$last_snapshot" != "$current_snapshot" ]; then
                echo "Обнаружены изменения в папке $target в $(date '+%Y-%m-%d %H:%M:%S')"
                last_snapshot=$current_snapshot
            fi
            
            if [ -n "$current_users" ]; then
                echo "Файлы в папке $target открыты пользователем(ями): $current_users"
            fi
            
            # Проверяем существование папки
            if [ ! -d "$target" ]; then
                echo "Папка $target была удалена!"
                exit 1
            fi
        fi
        
        sleep 1
    done
}

watch_target "$1"