#!/bin/bash
TRIGGER_FILE="/var/lib/docker/volumes/nextcloud_aio_nextcloud/_data/recognize.trigger"

echo "Фоновый ИИ-демон запущен и ожидает задач от Nextcloud 31..."

while true; do
    if [ -f "$TRIGGER_FILE" ]; then
        echo "[$(date)] Обнаружен триггер! Запуск распознавания видео..."
        
        # Вызываем ОРИГИНАЛЬНЫЙ occ внутри нашего Debian-воркера
        docker run --rm \
          --net=nextcloud-aio \
          -v /var/lib/docker/volumes/nextcloud_aio_nextcloud/_data:/var/www/html:rw \
          -v /var/lib/docker/volumes/nextcloud_aio_nextcloud_data/_data:/mnt/ncdata:rw \
          -e EXECUTE_IN_NODE=1 \
          nextcloud-recognize-worker php /var/www/html/occ.original recognize:classify
          
        rm -f "$TRIGGER_FILE"
        echo "[$(date)] Задача успешно выполнена."
    fi
    sleep 2
done
