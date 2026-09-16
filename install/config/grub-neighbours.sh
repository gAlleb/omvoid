#!/bin/bash

# Меню GRUB собирается в chroot, а os-prober там слеп: он перебирает блочные
# устройства через udev, сокет которого лежит в /run -- а установщик пробрасывает
# в цель только /dev, /proc и /sys. Ошибки при этом нет, просто соседние системы
# не находятся, и на машине с Windows в меню остаётся один Void.
#
# Поэтому пересборка откладывается до первой настоящей загрузки: /etc/rc.local
# выполняется от root в stage 2, когда udev уже поднят, а маркер не даёт этому
# повториться на каждом старте.

# Void кладёт rc.local в base-system, но если его нет, дописывать некуда: файл
# без бита исполнения runit просто не запустит.
if [[ ! -x /etc/rc.local ]]; then
  printf '#!/bin/sh\n' | sudo tee /etc/rc.local >/dev/null
  sudo chmod +x /etc/rc.local
fi

# Без этой проверки повторный прогон шага припишет блок второй раз.
grep -q 'grub-neighbours-done' /etc/rc.local || sudo tee -a /etc/rc.local >/dev/null <<'EOF'

if [ ! -e /var/lib/omvoid/grub-neighbours-done ]; then
  grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
  mkdir -p /var/lib/omvoid && touch /var/lib/omvoid/grub-neighbours-done
fi
EOF
