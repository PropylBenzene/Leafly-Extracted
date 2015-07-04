require 'rubygems'
require 'json'
require 'jsonpath'

locations = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X POST "http://data.leafly.com/locations" -d 'page=0&take=5&latitude=45.4278&longitude=-122.7789'`

locations_parsed = JSON.parse(locations)

isolate_slugs = JsonPath.new('$.stores[?(@.name != "")]')
slugs = isolate_slugs.on(locations)
e = slugs.each.map { |x| x["name"]}
f = slugs.each.map { |x| x["slug"]}
names = f.zip(e)

@sata = ""
@b
@results
@formatted_data
@something = Array.new
names.each do |x|
puts x.inspect
puts x
@sata += `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X GET "http://data.leafly.com/locations/#{x[0]}/menu"`
puts Hash[*x.flatten]
@sata.gsub!("\\/", "/") #\\ is for escaping the \
@sata.gsub!("][", ",")
@b = JSON.parse(@sata)
@b.each { |z| z["Store"] = x[0] }
isolate_concentrate = JsonPath.new('$.[?(@.type == "Concentrate")]')
@formatted_data = isolate_concentrate.on(@b)
@something += @formatted_data
c = @something.each.map {|x| x["name"]}
d = @something.each.map {|x| x["pricing"]}
e = @something.each.map {|x| x["Store"]}
@results = c.zip(d,e) #Combines the name and pricing together 
@results.reject! { |y| y[1][0].nil? }
sleep(5)
end

Hash[*names.flatten]
@results.sort_by! do |x|
	puts x.inspect
	x[1][0]["Price"]
end
#Puts the output out.
@results.each do |x|
puts "[%-45s]" % "#{x[0]}" + "[%-30s]" % "#{x[2]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
end

