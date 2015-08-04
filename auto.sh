#! /bin/bash

#Working Directory
cd Leaf/Leafly-Extracted

#Download Database
ruby leaf.rb > /dev/null && echo "Download of Database Complete"

#Pull Out Requested Data
ruby leaf-read.rb Concentrate Name > /dev/null
ruby leaf-read.rb Concentrate Price > /dev/null
ruby leaf-read.rb Flower Name > /dev/null
ruby leaf-read.rb Flower Price > /dev/null
echo "Creation of TXT's Complete"

#Create PDF's
enscript FlowerSortByName.txt -r -o - | ps2pdf - FlowerSortByName.pdf
enscript FlowerSortByPrice.txt -r -o - | ps2pdf - FlowerSortByPrice.pdf
enscript ConcentrateSortByName.txt -r -o - | ps2pdf - ConcentrateSortByName.pdf
enscript ConcentrateSortByPrice.txt -r -o - | ps2pdf - ConcentrateSortByPrice.pdf
echo "Creation of PDF's Copmlete"

#Copy the raw dumps into dated folders.
timestamp() {
  date '+%m-%d-%y'
}

mkdir /home/benzene/"$(timestamp)"
cp /home/benzene/Leaf/Leafly-Extracted/*.txt /home/benzene//"$(timestamp)"/
rm /home/benzene/Leaf/Leafly-Extracted/*.txt
echo "Copied Over TXT files for Backup"

#Dumps latest rethinkdb database incase of a crash.
rethinkdb dump -c 127.0.0.1:28015

echo "Database Backed Up"
echo "Executing FTP"

#Execute the FTP.
./ftp.sh
