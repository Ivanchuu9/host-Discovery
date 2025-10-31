# 🕵️‍♂️ hostDiscovery.sh

**hostDiscovery.sh** es un script en **Bash** que permite descubrir hosts activos en una red local y escanear sus puertos abiertos de forma rápida, sencilla y concurrente.  
Ideal para tareas de auditoría, pruebas de red o aprendizaje sobre escaneo TCP básico en Bash.

---

## 🚀 Características

- 🔍 Descubre automáticamente hosts activos con `nmap -sn`
- ⚡ Escaneo concurrente configurable (por defecto 64 procesos)
- 🌈 Salida con colores y formato legible en terminal
- 🔒 Compatible con `set -euo pipefail`
- 🧠 Validación de formato IPv4 con soporte opcional para CIDR (`/24`, `/16`, etc.)
- 💬 Resultados mostrados en tiempo real

---

## ⚙️ Requisitos

Asegúrate de tener instalados:

- **bash** (v4 o superior)
- **nmap** (para el descubrimiento de hosts)
- **timeout** (normalmente incluido en GNU coreutils)

Instalación en Debian/Ubuntu:

```bash
sudo apt install nmap coreutils -y


-- ⚠️ Aviso legal --

Este script está diseñado para fines educativos y de auditoría en redes propias o con permiso explícito.
El autor no se hace responsable del uso indebido de esta herramienta.


--  📄 Licencia --

Este proyecto está bajo la licencia MIT.
Consulta el archivo LICENSE para más detalles.


-- 💡 Autor -- 

📧 ivanchujc9@gmail.com

💻 https://github.com/ivanchuu9
