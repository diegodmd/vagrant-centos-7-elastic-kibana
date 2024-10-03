#!/bin/bash

echo-green() {
  echo -e "\n\n\e[32m$1\e[0m\n\n"
}
timedatectl set-timezone America/Sao_Paulo
timedatectl set-local-rtc 1

#atualização de pacotes
#echo -e "\nIniciando atualização de pacotes...\n"
#sudo yum -y update

#instalação do elastic
echo -e "\n\nIniciando instalação do Elastic...\n\n"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOL | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOL
sudo yum -y install --enablerepo=elasticsearch elasticsearch > /tmp/elasticsearch_install.log 2>&1
ELASTIC_PASSWORD=$(grep "The generated password for the elastic built-in superuser is" /tmp/elasticsearch_install.log | awk -F': ' '{print $2}')
sudo sed -i '56s/#network.host: 192.168.0.1/network.host: 192.168.1.2/' "/etc/elasticsearch/elasticsearch.yml"
sudo systemctl enable elasticsearch.service --now

#instalação do kibana
echo -e "\n\nIniciando instalação do Kibana...\n\n"
cat <<EOL | sudo tee /etc/yum.repos.d/kibana.repo
[kibana-8.x]
name=Kibana repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOL
sudo yum -y install kibana
sudo sed -i '11s/#server.host: "localhost"/server.host: 192.168.1.2/' "/etc/kibana/kibana.yml"
sudo systemctl enable kibana.service --now

#Configurando firewall
echo -e "\n\nConfigurando firewall...\n\n"
sudo systemctl start firewalld.service
sudo firewall-cmd --permanent --add-port=5601/tcp && firewall-cmd --permanent --add-port=9200/tcp
sudo systemctl restart firewalld

#Gerando tokens e senhas
echo -e "\nGerando tokens e senhas..."
cd /usr/share/elasticsearch/bin/ && sudo ./elasticsearch-create-enrollment-token --scope kibana > /tmp/kibana_token.log 2>&1
sudo ./elasticsearch-create-enrollment-token --scope kibana > /tmp/kibana_token.log 2>&1
KIBANA_TOKEN=$(cat /tmp/kibana_token.log)
echo-green "Importante! Guarde as informações abaixo:"
echo -e "Kibana Enrollment Token: $KIBANA_TOKEN\n"
echo -e "A senha gerada para o usuário superuser do Elasticsearch é: $ELASTIC_PASSWORD\n"
sudo su -
cd /usr/share/kibana/bin/
./kibana-verification-code
echo-green "Acesse o endereço 192.168.1.2:5601 no navegador e insira os tokens e senhas geradas para terminar a configuração"