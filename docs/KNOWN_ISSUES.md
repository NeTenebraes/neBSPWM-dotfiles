# 🐛 Errores Conocidos

Lista de problemas detectados y sus posibles *workarounds*. Si encuentras algo nuevo, por favor abre un [Issue](https://github.com/NeTenebraeso/neBSPWM-dotfiles/issues).

| Componente | Problema | Workaround |
| :--- | :--- | :--- |
| **VirtualBox** | Error al inicializar VirtualBox luego de un fresh install (módulos de kernel no cargados). | Ejecutar `sudo vboxreload` para carga manual o `sudo systemctl enable --now vboxdrv` para inicio persistente. |

### 🔍 Notas de Hardware
- **Laptops:** El módulo de batería puede variar según el nombre de la interfaz (`BAT0` vs `BAT1`).
---
[⬅️ Volver al README](../README.md)
