#! /bin/bash

## Amazon testing -- nixay -- control security with security groups
cat << EOF >> /etc/security/limits.conf
root soft nofile 655350
root hard nofile 655350
#new end of file
EOF


## R INSTALLATION
## let's grab the latest R version; alter sources.list and export a key
UBUNTU_RELEASE=`lsb_release -sc`
echo "deb http://cran.r-project.org/bin/linux/ubuntu $UBUNTU_RELEASE/" >> /etc/apt/sources.list
gpg --export --armor E2A11821 | sudo apt-key add -    

cat <<EOF >> /etc/R/Rprofile.site
options(repos = c(CRAN = "http://cran.cnr.berkeley.edu"))

EOF


R_INIT=/tmp/rinit
cat <<EOF > $R_INIT
install.packages(c('DBI','RPostgreSQL'),dependencies=TRUE)

EOF
R --no-restore --no-save --file=$R_INIT

## now run apt-get update & install
apt-get update

apt-get install -y r-base
apt-get install -y apache2
apt-get install -y apache2-threaded-dev
apt-get install -y emacs22-nox
apt-get install -y ess
apt-get install -y screen
apt-get install -y r-cran-rmysql
apt-get install -y r-cran-cairodevice

# apt-get install -y libxt-dev
wget http://biostat.mc.vanderbilt.edu/rapache/files/rapache-1.1.8.tar.gz
tar xvzf rapache-1.1.8.tar.gz
cd rapache-1.1.8
./configure
make
make install

LOG=/mnt/var/log/apache2
mkdir -p $LOG

cat << EOF > /etc/apache2/sites-available/rapache 
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www
  <Directory />
    AllowOverride None
  </Directory>

  Include /etc/apache2/mods-enabled/R_module.conf                                  
  Include /etc/apache2/mods-enabled/R_module.load                                  

  <Directory /var/www/>
    AllowOverride None
    Order allow,deny
    allow from all
    ROutputErrors                                                                  
    Options indexes FollowSymLinks                                                 
    SetHandler r-script                                                            
    RHandler sys.source                                                            
    REvalOnStartup "library(DBI); (RMySQL); library(Cairo);"                       
  </Directory>

  <Location /RApacheInfo>
    SetHandler r-info
  </Location>

  ErrorLog $LOG/error.log

  # Possible values include: debug, info, notice, warn, error, crit,
  # alert, emerg.
  LogLevel warn

  CustomLog $LOG/access.log combined
</VirtualHost>
EOF

a2enmod dump_io negotiation mime
a2dismod alias autoindex dir deflate cgid status env setenvif auth_basic authn_file authz_groupfile authz_user authz_default
a2dissite default
a2ensite rapache

service apache2 restart



