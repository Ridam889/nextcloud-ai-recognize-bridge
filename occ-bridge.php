#!/usr/bin/env php
<?php
$args = $_SERVER["argv"];

if (count($args) > 1 && $args[1] === "recognize:classify") {
    echo "=== [AI Bridge] Native interception: direct launch of Debian-worker via socket (CPU Limit: 10 Threads) ===\n";

    // Запускаем воркер с ограничением мощности в 10 потоков
    $cmd = "docker run --rm --cpus=\"10\" "
         . "--net=nextcloud-aio "
         . "-v /var/lib/docker/volumes/nextcloud_aio_nextcloud/_data:/var/www/html:rw "
         . "-v /var/lib/docker/volumes/nextcloud_aio_nextcloud_data/_data:/mnt/ncdata:rw "
         . "-e EXECUTE_IN_NODE=1 "
         . "nextcloud-recognize-worker php /var/www/html/occ.original recognize:classify";

    passthru($cmd);
} else {
    require_once __DIR__ . "/occ.original";
}
