#!/usr/bin/env bash
# ~/.config/bspwm/scripts/monitor/get_state.sh

# Genera una huella digital basada en hardware real (Kernel)
# Incluye: Estado de puertos, tapa (LID) y archivos de override
cat /sys/class/drm/card*-*/status \
    /proc/acpi/button/lid/*/state \
    /tmp/monitor_override_mode \
    /tmp/monitor_override_topology 2>/dev/null | md5sum | cut -d' ' -f1