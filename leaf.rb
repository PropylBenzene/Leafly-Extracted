require 'rubygems'
require 'json'
require 'jsonpath'
require 'rethinkdb'
include RethinkDB::Shortcuts
cellar = r.connect(:host=>"localhost", :port=>"28015")
igor = r
time = Time.now.year.to_s. + "_" + Time.now.month.to_s + "_" + Time.now.day.to_s + "_" + Time.now.hour.to_s
@names = Array.new

#This section loops to get the slugs for the menu pulls - Should have a condition to keep looping i++ until nil returns.
for i in 0..2 do
locations = `curl -v -H "app_id:6682ef51" -H "app_key:55c6b0efcd2e2549ff360a5dde136a50" -X POST "http://data.leafly.com/locations" -d 'page=#{i}&take=505&latitude=45.4278&longitude=-122.7789'`
locations_parsed = JSON.parse(locations)
isolate_slugs = JsonPath.new('$.stores[?(@.name != "")]')
slugs = isolate_slugs.on(locations_parsed)
e = slugs.each.map { |x| x["name"]}
f = slugs.each.map { |x| x["slug"]}
compiled = f.zip(e)
@names += compiled
sleep(3)
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
sleep(10)

end
end
