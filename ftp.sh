#!/bin/bash

HOST=ftp.extractme.esy.es  #This is the FTP servers host or IP address.
USER=u305857047.ftp             #This is the FTP user that has access to the server.
PASS=Contagion123X          #This is the password for the FTP user.

# Call 1. Uses the ftp command with the -inv switches. 
#-i turns off interactive prompting. 
#-n Restrains FTP from attempting the auto-login feature. 
#-v enables verbose and progress. 

ftp -inv $HOST << EOF

# Call 2. Here the login credentials are supplied by calling the variables.

user $USER $PASS

# Call 3. Here you will change to the directory where you want to put or get
# cd /public_html

# Call4.  Here you will tell FTP to put or get the file.
put ConcentrateSortByName.pdf
put ConcentrateSortByPrice.pdf
put FlowerSortByName.pdf
put FlowerSortByPrice.pdf

# End FTP Connection
bye

EOF
