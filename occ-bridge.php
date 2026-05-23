#!/usr/bin/env php
<?php
$args = $_SERVER["argv"];
if (count($args) > 1 && $args === "recognize:classify") {
    $currentTime = date("H:i:s");
    echo "=== [AI Bridge] Intercepted: Request sent to Debian Host ===\n";
    echo "[AI Bridge] Current container time: [$currentTime]. Processing instantly... \n";
    
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
}
