#! /bin/bash

# check root user
if [[ $(id -u) != 0 ]]; then
    echo "Require administrative priviledge."
    echo "This pseudo command 'sudo ls' use for enter sudo session."
    echo "\$ sudo ls"
    sudo ls &> /dev/null
else
    echo "Run this script as root."
fi

# cleanup directory before process

sudo rm -rf generated
sudo mkdir -p generated

# create temp container for copy file in image
printf "\nRunning temporary container...\n"
container_id=$(sudo docker run --rm -d sequenceiq/hadoop-docker:2.7.1 bash -c "while true; do sleep 1800; done;")
sudo docker cp $container_id:/tmp generated/hadoop_files
sudo docker cp $container_id:/root/.ssh/ generated/ssh

# generate ssh key
printf "\ngenerate ssh key\n"
echo -e 'y\n' | ssh-keygen -t rsa -N '' -f id_rsa -C noname
sudo cp -f id_rsa.pub generated/ssh/authorized_keys
sudo cp -f id_rsa.pub generated/ssh/
sudo cp -f id_rsa generated/ssh/

# stop temp container
printf "\nStopping temporary container...\n"
sudo docker stop $container_id &> /dev/null

cat << EOF

Finished initialize container.
SSH private key store in id_rsa file.
You can run container by

$ sudo docker-compose up -d

EOF


