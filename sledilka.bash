#!/usr/bin/env bash

watch_file() {
    local file="$1"
    local last_modified=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file")
    local last_users=""
    
    echo "Начинаю следить за файлом: $file"
    echo "Нажмите Ctrl+C для остановки" 
    
    while true; do
        current_modified=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file")
        current_users=$(lsof "$file" 2>/dev/null | awk 'NR>1 {print $3}' | sort -u | tr '\n' ',' | sed 's/,$//')
        
        if [ "$last_users" != "$current_users" ]; then
            if [ -z "$current_users" ]; then
                echo "Файл $file сейчас никем не открыт"
            else
                echo "Файл $file сейчас открыт пользователем(ями): $current_users"
            fi
            last_users=$current_users
        fi
        
        if [ "$last_modified" != "$current_modified" ]; then
            echo "Файл $file был изменен в $(date '+%Y-%m-%d %H:%M:%S')"
            last_modified=$current_modified
        fi
        
        # Проверяем существование файла
        if [ ! -f "$file" ]; then
            echo "Файл $file был удален!"
            exit 1
        fi
        
        sleep 1
    done
}