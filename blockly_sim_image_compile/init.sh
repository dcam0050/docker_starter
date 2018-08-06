sudo service ssh start
ssh -f icub@$HOSTNAME echo 'ssh setup complete'
sudo ldconfig
ssh-copy-id pc104