require 'rubygems'
require 'json'
require 'jsonpath'
require 'rethinkdb'
include RethinkDB::Shortcuts

app_id = ""
app_key = ""
cellar = r.connect(:host=>"localhost", :port=>"28015")
igor = r
time = Time.now.year.to_s. + "_" + Time.now.month.to_s + "_" + Time.now.day.to_s + "_" + Time.now.hour.to_s
@names = Array.new
@gps = String.new

#This section loops to get the slugs for the menu pulls - Should have a condition to keep looping i++ until nil returns.
for i in 0..2 do

locations_tigard = `curl -v -H "#{app_id}" -H "#{app_key}" -X POST "http://data.leafly.com/locations" -d 'page=#{i}&take=50&latitude=45.4278&longitude=-122.7789'`
locations_portland = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X POST "http://data.leafly.com/locations" -d 'page=#{i}&take=50&latitude=45.5200&longitude=-122.6819'`
locations_tigard_parsed = JSON.parse(locations_tigard)
locations_portland_parsed = JSON.parse(locations_portland)

#Need this corrected for isolating the name. $(Root Object).(Hash Name)stores[?(Filter)(@.name != "")(Inside the Current Object by the hash name "name" for anything that doesn't have "name" blank!)
isolate_slugs = JsonPath.new('$.stores[?(@.name != "")]')
slugs_tigard = isolate_slugs.on(locations_tigard_parsed)
slugs_portland = isolate_slugs.on(locations_portland_parsed)
e = slugs_tigard.each.map { |x| x["name"]}
f = slugs_tigard.each.map { |x| x["slug"]}
g = slugs_portland.each.map { |x| x["name"]}
h = slugs_portland.each.map { |x| x["slug"]}
lat_tigard = slugs_tigard.each.map { |x| x["latitude"]}
lon_tigard = slugs_tigard.each.map { |x| x["longitude"]}
lat_portland = slugs_portland.each.map { |x| x["latitude"]}
lon_portland = slugs_portland.each.map { |x| x["longitude"]}

compiled_tigard = f.zip(e,lat_tigard,lon_tigard)
compiled_portland = h.zip(g,lat_portland,lon_portland)
@names += compiled_tigard
@names += compiled_portland
sleep(1)
end

#This section takes the names, sorts out the -'s to _'s and then sorts out the databases that are present versus ones that need to be created. I couldn't figure out the exception handling.

simple = @names

simple.each { |x| x[0].gsub!("-", "_") }
current = igor.db_list.run(cellar)
to_create = simple.each.map { |x| x[0] }
not_included = (to_create - current).to_a
not_included = not_included.uniq

not_included.each do |x|
igor.db_create("#{x}").run(cellar) 
end

#This section drops through and drops the raw, parsed JSON from the menus into the databases.


@results
@compiled = Array.new
@data = String.new
check = Array.new

@names.each do |x|
x[0].gsub!("-", "_")
puts x
check = igor.db("#{x[0]}").table_list.run(cellar).to_a
puts check.include?(time)

if check.include?(time) == true
	next
else
x[0].gsub!("_", "-")
sata = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X GET "http://data.leafly.com/locations/#{x[0]}/menu"`
sata.gsub!("\\/", "/") #\\ is for escaping the \
sata.gsub!("][", ",")

begin
brains = JSON.parse(sata)
	rescue
		next
end

brains.each { |z| z["Store"] = x[0] } #This is added to inject the stored names along each array of data to be pulled later.
x[0].gsub!("-", "_")
igor.db("#{x[0]}").table_create("#{time}").run(cellar)
igor.db("#{x[0]}").table("#{time}").insert(brains).run(cellar)
sleep(1)

end
end
@names.uniq!
@names.each do |x|
	@gps += x.join("\t") + "\n"
end

output = File.open("gps.txt", "w")
output.puts @gps
output.close
