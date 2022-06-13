#! /bin/sh
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo aws s3 cp s3://s3-deni-ccp-cdn-bucket/docker-compose.yml /opt
cd /opt
docker-compose up -d
sudo rm -rf docker-compose.yml