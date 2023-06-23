# Microblog
Flask script for website 

# A. Development preparation
##  Step 1 : setting up gmail for password reset
Create .env file and set environment the following ENV variable

export MAIL_SERVER=smtp.googlemail.com
export MAIL_PORT=587
export MAIL_USE_TLS=1
export MAIL_USERNAME=<your-gmail-email>
export MAIL_PASSWORD=<your-gmail-password>
export MS_TRANSLATOR_KEY=<your-azur-translator-key>
export ELASTICSEARCH_URL=http://localhost:9200

## Step 2 : allow you gmail account to send emails
click on https://myaccount.google.com/lesssecureapps and  unlock

##  Step 3: setting up virtual environment
- setting the right python version using pyenv
- running `pipenv install`

## Step 4 : running flask
- sh boot_develop.sh

# Production Details
Most of the following steps are inspired by Ginberg's tutorial (see tutorial doc) 
## Step 0 : create a VM instance on GCP

##  Step 1 : ssh connect
ssh connect to instance through GCP

## Step 2 : git pull 
- sudo apt-get -y update
- sudo apt-get -y install git
- generate keys in .ssh folder (ssh-keygen)
- add keys to github
- clone repo

## Step 3 : create docker environment (https://docs.docker.com/engine/install/debian/)
Check whether you're debian or ubuntu
- sudo apt install -y make

## Step 4 : try to access app externally (firewall)
https://amanranjanverma.medium.com/run-flask-app-on-gcp-compute-engine-vm-instance-de4aea60a6fe

- create a network tag (allow-80)
- Go https://console.cloud.google.com/networking/firewalls/
- create firewall rule (http-allow-80)
- add tag (allow-80)
- specify TCP (port 80)
- look at externel IP adress

(obsolete)
# Step 3 : prepare .env
SECRET_KEY=(gen by python -c "import uuid; print(uuid.uuid4().hex)")
MAIL_SERVER=localhost
MAIL_PORT=25
DATABASE_URL=mysql+pymysql://microblog:<db-password>@localhost:3306/microblog
MS_TRANSLATOR_KEY=<your-translator-key-here>

## 3.1 Setting up emails
see https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-debian-9
- with gmail, bypass additional security (captcha) by checking https://accounts.google.com/b/0/DisplayUnlockCaptcha
- without gmail, good luck...

## 3.2 Setting up elastic search
looks too intense for a small server

## 3.3 Setting up distrib
- redis : apt-get install redis-server + gunicorn
- cp /etc/supervisor/conf.d/microblog.conf
/etc/supervisor/conf.d/rq.conf (and adapt content)
(ideally adapting to multiple processes)
- sudo supervisorctl reload

# Step 4 : prepare languages
flask translate compile

# Step 5 : set up db
setting up db
mysql -u root -p
mysql> create database microblog character set utf8 collate utf8_bin;
mysql> create user 'microblog'@'localhost' identified by 'sZQ9NdjghCGykLwaWjPyfQUu';
mysql> grant all privileges on microblog.(star) to 'microblog'@'localhost';
mysql> flush privileges;
mysql> quit;

if issues :
USE mysql;
CREATE USER 'debian'@'localhost' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'debian'@'localhost';
UPDATE user SET plugin='unix_socket' WHERE User='debian';

# Step 6 : deploy
gunicorn file (/etc/supervisor/conf.d/microblog.conf):
[program:microblog]
command=/home/ubuntu/microblog/venv/bin/gunicorn -b localhost:8000 -w 4 microblog:app
directory=/home/ubuntu/microblog
user=ubuntu
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
where gunicorn is referenced from virtualenv

useful commands:
sudo supervisorctl status all
sudo supervisorctl reload
sudo vim /etc/nginx/sites-enabled/microblog
sudo nginx -c /etc/nginx/nginx.conf -t
sudo service nginx reload
service nginx status

# Step 7 : get certificate using certbot
see tutorial. If issues:
sudo apt-get install dirmngr
sudo certbot certonly --webroot -w /home/debian/microblog/app/static -d thementaldoctors.com

# Step 8 : update application
(venv) $ git pull                              # download the new version
(vend) $ (pipenv install) if modif made
(venv) $ sudo supervisorctl stop microblog     # stop the current server
(venv) $ flask db upgrade                      # upgrade the database
(venv) $ flask translate compile               # upgrade the translations
(venv) $ sudo supervisorctl start microblog    # start a new server

# Step 9 : misc

checking storage remaining:
df -H /dev/sda1
allow https on compute :)

# API Queries
- get token:
http --auth cvandekerckh:<password> POST https://thementaldoctors.com/api/tokens

- get user:
http GET https://thementaldoctors.com/api/users/1 \
    "Authorization:Bearer pC1Nu9wwyNt8VCj1trWilFdFI276AcbS"
