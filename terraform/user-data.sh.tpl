#!/bin/bash
set -e

REPO_URL="${repo_url}"
APP_DIR="/opt/jarvis-app"
USER="${owner_user}"

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip git

id -u ${USER} &>/dev/null || useradd -m -s /bin/bash ${USER}

if [ ! -d "${APP_DIR}" ]; then
  sudo -u ${USER} git clone "${REPO_URL}" "${APP_DIR}" || true
fi

cd ${APP_DIR}
sudo -u ${USER} git pull || true

python3 -m venv ${APP_DIR}/venv
. ${APP_DIR}/venv/bin/activate
pip install --upgrade pip
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

# Adjust entrypoint if necessary (jarvis.py assumed)
cat > /etc/systemd/system/jarvis.service <<EOF
[Unit]
Description=Jarvis Desktop Voice Assistant
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${APP_DIR}
ExecStart=${APP_DIR}/venv/bin/python ${APP_DIR}/jarvis.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jarvis.service
systemctl restart jarvis.service || true

chown -R ${USER}:${USER} ${APP_DIR}
