sudo apt-update
echo "deb https://packages.elastic.co/kibana/5.0/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana.list
sudo apt-get install elasticsearch -y
sudo apt-get install kibana -y

sudo systemctl enable kibana
sudo systemctl start kibana
