require 'rubygems'
require 'json'
require 'jsonpath'

#Pulls ALL of menu from Human Collective
data = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X GET "http://data.leafly.com/locations/human-collective/menu"`

#This results in HASHES embedded inside of an Array!!!!!
#you grab the hashes by calling formatted_data[40]['name']
isolate_concentrate = JsonPath.new('$.[?(@.type == "Concentrate")]')
formatted_data = isolate_concentrate.on(data)

#Sample return:

# 
#  "name": "WAX - (PROPER) OG KUSH BHO",
#  "description": "THC. 85.6%\nCBD. 1.08%",
#  "addedOn": "/Date(1425082580488+0000)/",
#  "type": "Concentrate",
#  "pricing": [
#   {
#    "Unit": "Gram",
#    "Price": 19
#   }
#  ]
 #}


#This sequence collects all the 'names' from the array.
c = formatted_data.each.map {|x| x["name"]}
d = formatted_data.each.map {|x| x["pricing"]}
results = c.zip(d) #Combines the name and pricing together intensically. Next to filter out the percentage ranking to sort between the types offered and to sort by price etc.
some = results[1..10] # This is needed to have a reduced amount to interact with in the IRB.
#This creates this kind of formatting - :
#[BUBBLE HASH - (BB) 1g DURBAN POISON          ][Gram     ][15.0 ]
#[CART .3G LEMON SKUNK                         ][0.3g     ][14.0 ]
#[CART .3G OG KUSH OV                          ][HalfGram ][17.0 ]
#[CART .3G PINECONE BLEND OV	                  ][HalfGram ][17.0 ]
#[CART .3G SHISHKABERRY OV                     ][HalfGram ][17.0 ]
#[CART .4 GOD'S GIFT (TRUE NORTH)              ][Gram     ][17.5 ]
#[CART .4 LEMON SKUNK (TRUE NORTH)             ][Gram     ][17.5 ]
#[CART .4G AOTA (TRUE NORTH)                   ][Gram     ][17.5 ]
#[CART .5G THE FUEL (SHANGO)                   ][Half Gram][23.0 ]
#[CART 1G BLUE ASIAN DREAM                     ][Gram     ][22.75]
#
#It is obvious what needs fixed. I dunno how though.
some.each do |x|
puts "[%-45s]" % "#{x[0]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
end

