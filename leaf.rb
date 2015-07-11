require 'rubygems'
require 'json'
require 'jsonpath'
require 'rethinkdb'
include RethinkDB::Shortcuts


@names = Array.new
for i in 0..2 do
locations = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X POST "http://data.leafly.com/locations" -d 'page=#{i}&take=1&latitude=45.4278&longitude=-122.7789'`
locations_parsed = JSON.parse(locations)
isolate_slugs = JsonPath.new('$.stores[?(@.name != "")]')
slugs = isolate_slugs.on(locations_parsed)
e = slugs.each.map { |x| x["name"]}
f = slugs.each.map { |x| x["slug"]}
compiled = f.zip(e)
@names += compiled
sleep(3)
end




@results
@compiled = Array.new
cellar = r.connect(:host=>"localhost", :port=>"28015")
igor = r
time = Time.now.year.to_s. + "_" + Time.now.month.to_s + "_" + Time.now.day.to_s + "_" + Time.now.hour.to_s
@data = String.new

@names.each do |x|
puts x
@data += `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X GET "http://data.leafly.com/locations/#{x[0]}/menu"`

@data.gsub!("\\/", "/") #\\ is for escaping the \
@data.gsub!("][", ",")

parsed_data = JSON.parse(@data)
parsed_data.each { |z| z["Store"] = x[0] } #This is added to inject the stored names along each array of data to be pulled later.
x[0].gsub!("-", "_")
brains = parsed_data
igor.db_create("#{x[0]}").run(cellar)
igor.db("#{x[0]}").table_create("#{time}").run(cellar)
igor.db("#{x[0]}").table("#{time}").insert(brains).run(cellar)

isolate_concentrate = JsonPath.new('$.[?(@.type == "Flower")]')
formatted_data = isolate_concentrate.on(parsed_data)
@compiled += formatted_data
c = @compiled.each.map {|x| x["name"]}
d = @compiled.each.map {|x| x["pricing"]}
e = @compiled.each.map {|x| x["Store"]}
@results = c.zip(d,e) #Combines the name and pricing together 
@results.reject! { |y| y[1][0].nil? }
sleep(7)
end

Hash[*@names.flatten]
@results.sort_by! do |x|
	x[1][0]["Price"]
end
#Puts the output out.

@results.each do |x|
puts "[%-45s]" % "#{x[0]}" + "[%-30s]" % "#{x[2]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
end
