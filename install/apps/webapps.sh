#!/bin/bash

omvoid-webapp-install "omFM" https://omfm.ru/ omFM.png
omvoid-webapp-install "WhatsApp" https://web.whatsapp.com/ WhatsApp.png
omvoid-webapp-install "AIstudio" https://aistudio.google.com/ AIstudio.png
omvoid-webapp-install "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
omvoid-webapp-install "GitHub" https://github.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png

sed -i 's|^source $OMVOID_INSTALL/apps/webapps.sh\s*$|#source $OMVOID_INSTALL/apps/webapps.sh|' ~/.local/share/omvoid/install.sh
