# 🌉 Nextcloud AI Recognize Bridge

> Автоматический AI-мост для Nextcloud 31 AIO с AVX2 ускорением

## 📦 Установка

```bash
curl -fsSL https://raw.githubusercontent.com/Ridam889/nextcloud-ai-recognize-bridge/refs/heads/main/core.sh | bash
🗑️ Удаление
bash

curl -fsSL https://raw.githubusercontent.com/Ridam889/nextcloud-ai-recognize-bridge/refs/heads/main/core.sh | bash -s uninstall
📋 Требования
Компонент	Версия
Nextcloud AIO	v31+
Docker	24.0+
CPU	AVX2 + FMA
RAM	4GB
🔧 Устранение проблем
Проблема	Решение
❌ AVX2 не найден	grep avx2 /proc/cpuinfo
🐳 Docker ошибка	systemctl restart docker
🔒 Нет доступа	sudo usermod -aG docker $USER
💀 Контейнер не стартует	docker logs nextcloud-ai-bridge
📄 Лицензия

MIT © Ridam Sobuz

⭐ Поставь звезду на GitHub, если проект полезен!
