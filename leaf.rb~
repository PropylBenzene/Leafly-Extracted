require 'rubygems'
require 'json'
require 'jsonpath'

#--------------This chunk deals with getting the Location Slugs--
#Returns a long string  vvv

locations = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X POST "http://data.leafly.com/locations" -d 'page=0&take=20&latitude=45.4278&longitude=-122.7789'`

#This parses it out, but into a HASH named 'stores' which houses an array that must be iterated through for "name".
locations_parsed = JSON.parse(locations)
#Need this corrected for isolating the name. $(Root Object).(Hash Name)stores[?(Filter)(@.name != "")(Inside the Current Object by the hash name "name" for anything that doesn't have "name" blank!)
isolate_slugs = JsonPath.new('$.stores[?(@.name != "")]')
slugs = isolate_slugs.on(locations)
e = slugs.each.map { |x| x["name"]}
f = slugs.each.map { |x| x["slug"]}
names = f.zip(e)

#-------This loop iterates through the slugs for their menu!-----

@sata = ""
names.each do |x|
@sata += `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X GET "http://data.leafly.com/locations/#{x[0]}/menu"`
sleep(5)
end

@sata.gsub!("\\/", "/") #\\ is for escaping the \
@sata.gsub!("][", ",")
b = JSON.parse(@sata)

isolate_concentrate = JsonPath.new('$.[?(@.type == "Concentrate")]')
formatted_data = isolate_concentrate.on(b)

c = formatted_data.each.map {|x| x["name"]}
d = formatted_data.each.map {|x| x["pricing"]}
results = c.zip(d) #Combines the name and pricing together 
 
#Up until this point, it works perfectly.
#The sorting needs to default the nil to a zero.

results.reject! { |x| x[1][0].nil? }

results.sort_by! do |x|
	puts x.inspect
	x[1][0]["Price"].to_i
end
@a
#Puts the output out.
results.each do |x|
puts "[%-45s]" % "#{x[0]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
end


#--How to write a file.
output = File.open( "prices.txt","w" )
output.write @a
output.close

