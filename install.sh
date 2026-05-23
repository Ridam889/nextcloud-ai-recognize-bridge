#!/bin/bash

ACTION=$1
AIO_APPS="/var/lib/docker/volumes/nextcloud_aio_nextcloud/_data/custom_apps"
AIO_HTML="/var/lib/docker/volumes/nextcloud_aio_nextcloud/_data"

if [ "$ACTION" == "uninstall" ]; then
    echo "=== [AI Deployer] Starting full uninstallation and cleanup ==="
    
    # 1. Возвращаем оригинальный заводской occ на место
    if [ -f "$AIO_HTML/occ.original" ]; then
        rm -f "$AIO_HTML/occ"
        cp "$AIO_HTML/occ.original" "$AIO_HTML/occ"
        chmod 755 "$AIO_HTML/occ"
        chown 33:33 "$AIO_HTML/occ"
        rm -f "$AIO_HTML/occ.original"
    fi
    rm -f "$AIO_HTML/occ-bridge.php"

    # 2. Удаляем плагин
    rm -rf "$AIO_APPS/ai_bridge"
    docker exec --user www-data -w /var/www/html nextcloud-aio-nextcloud php occ app:remove ai_bridge 2>/dev/null

    # 3. Стираем Docker-образ
    docker rmi -f nextcloud-recognize-worker 2>/dev/null
    echo "=== [AI Deployer] System is completely clean now ==="
    exit 0
fi

echo "=== [AI Deployer] Starting automated deployment from GitHub ==="

# 1. Воссоздаем чистую структуру папок
mkdir -p "$AIO_APPS/ai_bridge/appinfo"
mkdir -p "$AIO_APPS/ai_bridge/lib/BackgroundJob"

# 2. Записываем манифест info.xml
echo '<?xml version="1.0" standalone="yes"?>
<app>
    <id>ai_bridge</id>
    <name>AI Container Bridge</name>
    <summary>Automated link recovery for external Debian AI worker</summary>
    <description>Maintains host tasks and occ interception script across container restarts.</description>
    <version>1.0.0</version>
    <licence>AGPL</licence>
    <author>Admin</author>
    <namespace>AiBridge</namespace>
    <category>tools</category>
    <dependencies>
        <nextcloud min-version="31" max-version="31" />
    </dependencies>
</app>' > "$AIO_APPS/ai_bridge/appinfo/info.xml"

# 3. Записываем Application.php
echo '<?php
namespace OCA\AiBridge\AppInfo;
use OCP\AppFramework\App;
class Application extends App {
    public function __construct(array $urlParams = []) { parent::__construct("ai_bridge", $urlParams); }
}' > "$AIO_APPS/ai_bridge/appinfo/Application.php"

# 4. Записываем ClassifyJob.php
echo '<?php
namespace OCA\AiBridge\BackgroundJob;
use OCP\BackgroundJob\TimedJob;
class ClassifyJob extends TimedJob {
    public function __construct() { $this->setInterval(300); }
    protected function run($argument) {
        $trigger = "/var/www/html/recognize.trigger";
        $logFile = "/var/www/html/recognize.log";
        if (file_exists($trigger)) {
            $cmd = "docker run --rm --cpus=\"10\" --net=nextcloud-aio "
                 . "-v /var/lib/docker/volumes/nextcloud_aio_nextcloud/_data:/var/www/html:rw "
                 . "-v /var/lib/docker/volumes/nextcloud_aio_nextcloud_data/_data:/mnt/ncdata:rw "
                 . "-e EXECUTE_IN_NODE=1 "
                 . "nextcloud-recognize-worker php /var/www/html/occ.original recognize:classify > $logFile 2>&1";
            shell_exec($cmd);
            @unlink($trigger);
        }
    }
}' > "$AIO_APPS/ai_bridge/lib/BackgroundJob/ClassifyJob.php"

# 5. Записываем occ-bridge.php
echo '#!/usr/bin/env php
<?php
$args = $_SERVER["argv"];
if (count($args) > 1 && $args === "recognize:classify") {
    echo "=== [AI Bridge] Intercepted: Request sent to Debian Host (TensorFlow CPU) ===\n";
    $trigger = __DIR__ . "/recognize.trigger";
    $logFile = __DIR__ . "/recognize.log";
    if (file_exists($logFile)) { @unlink($logFile); }
    touch($trigger);
    $lastPos = 0;
    while (file_exists($trigger)) {
        sleep(1);
        if (file_exists($logFile)) {
            clearstatcache(false, $logFile);
            $f = fopen($logFile, "rb");
            if ($f) {
                fseek($f, $lastPos);
                while (($line = fgets($f)) !== false) { echo $line; flush(); }
                $lastPos = ftell($f); fclose($f);
            }
        }
    }
    if (file_exists($logFile)) {
        $f = fopen($logFile, "rb");
        if ($f) { fseek($f, $lastPos); while (($line = fgets($f)) !== false) { echo $line; } fclose($f); @unlink($logFile); }
    }
    echo "=== [AI Bridge] Processing successfully finished ===\n";
} else {
    require_once __DIR__ . "/occ.original";
}' > "$AIO_HTML/occ-bridge.php"

# 6. Подменяем occ
if [ -f "$AIO_HTML/occ" ] && [ ! -f "$AIO_HTML/occ.original" ]; then
    cp "$AIO_HTML/occ" "$AIO_HTML/occ.original"
fi
echo '<?php require_once "/var/www/html/occ-bridge.php";' > "$AIO_HTML/occ"

# 7. Права доступа
chmod 755 "$AIO_HTML/occ" "$AIO_HTML/occ-bridge.php"
chmod -R 755 "$AIO_APPS/ai_bridge"
chown -R 33:33 "$AIO_APPS/ai_bridge" "$AIO_HTML/occ" "$AIO_HTML/occ-bridge.php" "$AIO_HTML/occ.original"

# 8. Включаем плагин внутри Nextcloud
docker exec --user www-data -w /var/www/html nextcloud-aio-nextcloud php occ app:enable ai_bridge --force 2>/dev/null

# 9. Сборка образа напрямую из репозитория GitHub
echo "[AI Deployer] Compiling Docker worker image from GitHub..."
docker build https://github.com/Ridam889/recognize-worker.git -t nextcloud-recognize-worker

echo "=== [AI Deployer] Automated deployment successfully completed! ==="
