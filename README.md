# Leafly-Extracted
This is a project to pull data reliably from their API to do at first price comparisson on multiple strains from multiple dispensaries. It will evolve.

Currently, there are two functions, one that drops all the menus into a rethinkdb and one that parses out the data from the rethinkdb. There is an included script that is called auto.sh. It will run all the programs needed for my needs and passes out everything as a PDF, third parties may need be installed, and I'm running XUBUNTU so ya know, linux.

Useage for leaf.rb is no command lines, simply let it run, default is set to Tigard, OR with an overlap to Portland, OR.

Useage for leaf-read.rb is ruby leaf-read.rb [Cateogry] [Price/Name] [Optional price to cut off at]

The data is displayed as [Product Name][Description][Store][Unit][Price]

The data is all displayed via embedded PDF's in my website : http://extractme.info which was built and maintained by Suessical.



