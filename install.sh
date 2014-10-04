#!/bin/bash

#mount -t tmpfs shmfs -o size=512m /dev/shm

date
/tmp/install/client/runInstaller -silent -responseFile /tmp/install/client_install.rsp -ignoreSysPrereqs -ignorePrereq -noconfig &
echo "Installation in progress on background"
while [ ! -f /oracle/oinventory/orainstRoot.sh ]; do
    echo "File /oracle/oinventory/orainstRoot.sh not found...waiting"
    sleep 300
done
date