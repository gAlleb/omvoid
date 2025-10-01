#!/bin/bash

omvoid-webapp-install "omFM" https://omfm.ru/ omFM.png
# omvoid-webapp-install "Google Photos" https://photos.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-photos.png
# omvoid-webapp-install "Google Contacts" https://contacts.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-contacts.png
# omvoid-webapp-install "Google Messages" https://messages.google.com/web/conversations https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-messages.png
# omvoid-webapp-install "ChatGPT" https://chatgpt.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png
omvoid-webapp-install "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
omvoid-webapp-install "GitHub" https://github.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png

sed -i 's|^source $OMVOID_INSTALL/apps/webapps.sh\s*$|#source $OMVOID_INSTALL/apps/webapps.sh|' ~/.local/share/omvoid/install.sh
