# Nextcloud AI Recognize Bridge 🚀

<p align="center">
  <img src="https://github.com/Ridam889/nextcloud-ai-recognize-bridge.git" width="120" height="120" alt="Logo">
</p>

Automated high-performance AI deployment and link recovery system for Nextcloud 31 (All-in-One). Offloads video and face classification from the slow Alpine environment directly into a native **Debian 12 worker** with full **AVX2 FMA** CPU acceleration.

## Features ✨
* **0% Host Overhead**: Fully automated via Nextcloud Background Jobs (Cron).
* **CPU Smart Throttling**: Hard-limited to 10 threads to keep your Proxmox host cool.
* **AIO Upgrade Proof**: Automatically reinstalls proxy hooks and directory structures on container restarts.

## Production Commands ⚡

### One-Click Installation & Deployment
```bash
curl -fsSL https://raw.githubusercontent.com/Ridam889/nextcloud-ai-recognize-bridge/refs/heads/main/core.sh | bash
```

### Complete Purge & Uninstallation
```bash
curl -fsSL https://raw.githubusercontent.com/Ridam889/nextcloud-ai-recognize-bridge/refs/heads/main/core.sh | bash -s uninstall
```
