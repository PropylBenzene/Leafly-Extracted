#!/bin/bash

HOST=f11-preview.biz.nf  #This is the FTP servers host or IP address.
USER=1942407          #This is the FTP user that has access to the server.
PASS=Password1!          #This is the password for the FTP user.

# Call 1. Uses the ftp command with the -inv switches. 
#-i turns off interactive prompting. 
#-n Restrains FTP from attempting the auto-login feature. 
#-v enables verbose and progress. 

ftp -p -inv $HOST << EOF

# Call 2. Here the login credentials are supplied by calling the variables.

user $USER $PASS

# Call 3. Here you will change to the directory where you want to put or get
# cd /public_html

# Call4.  Here you will tell FTP to put or get the file.

cd extractme.co.nf
put ConcentratesSortByName.pdf
put ConcentratesSortByPrice.pdf
put FlowersSortByName.pdf
put FlowersSortByPrice.pdf
put ClonesSortByPrice.pdf
put ClonesSortByName.pdf
put SeedsSortByName.pdf
put SeedsSortByPrice.pdf

# End FTP Connection
bye

EOF

#rm /home/benzene/Leaf/Leafly-Extracted/*.pdf && echo "Deleted PDF's"

#Dumps latest rethinkdb database incase of a crash.
rethinkdb dump -c 127.0.0.1:28015

echo "Database Backed Up"

pkill rethinkdb && echo "Shutdown"

apt-get purge -y rethinkdb && echo "Removed"
apt-get install -y rethinkdb && echo "Installed"

cd /home/benzene/rethinkdb_data
rm -r -f *
