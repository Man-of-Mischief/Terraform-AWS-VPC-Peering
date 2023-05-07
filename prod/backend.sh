############ backend.sh

#!/bin/bash

yum install mariadb105-server.x86_64 -y
systemctl start mariadb.service
systemctl enable mariadb.service
