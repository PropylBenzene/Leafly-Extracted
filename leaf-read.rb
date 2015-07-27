require 'rubygems'
require 'json'
require 'jsonpath'
require 'rethinkdb'
include RethinkDB::Shortcuts
cellar = r.connect(:host=>"localhost", :port=>"28015")
igor = r
time = Time.now.year.to_s. + "_" + Time.now.month.to_s + "_" + Time.now.day.to_s + "_" + Time.now.hour.to_s
@names = Array.new
@table_array = []

database_array = igor.db_list().run(cellar)

database_array.each do |x|
	tablelist = igor.db("#{x}").table_list().run(cellar).last
	@table_array << ["#{x}", "#{tablelist}"]
end

@table_array.reject! { |x| x[1].empty? }

@results = Array.new
@compiled = Array.new
@parsed_data
@formatted_data
@temp = []

@table_array.each do |x|
@parsed_data = igor.db("#{x[0]}").table("#{x[1]}").run(cellar)
@temp = @parsed_data.to_a
isolate_concentrate = JsonPath.new('$.[?(@.type == "#{ARGV[0]}")]')
@formatted_data = isolate_concentrate.on(@temp)
puts @formatted_data
@compiled += @formatted_data
c = @compiled.each.map {|x| x["name"]}
d = @compiled.each.map {|x| x["pricing"]} # Need to do a .each here to do the different units of pricing.
e = @compiled.each.map {|x| x["Store"]}
f = @compiled.each.map {|x| x["description"]}
@results = c.zip(d,e,f) #Combines the name and pricing together 
@results.reject! { |y| y[1][0].nil? }

if ARGV[2] != nil
	@results.reject! { |y| y[1][0]["Price"] > ARGV[2].to_i }
#	@results.reject! { |y| y[2][0]["Unit"] != "Gram" }
end
end

##sorts by ARGV[1].
Hash[*@names.flatten]

if ARGV[1].downcase == "price"
	@results.sort_by! do |x|
	x[1][0]["Price"]
	end
elsif 
	ARGV[1].downcase == "name"
	@results.sort_by! do |x|
	x[0]
	end
end

#Puts the output out.

tigardconcentratesortbyprice = ""

@results.each do |x|

if x[3] != nil
x[3].gsub!("\n", " ")
x[3].gsub!("   ", " ")
end
#puts "[%-60s]" % "#{x[0]}"[0..59] + "[%-30s]" % "#{x[3]}"[0..20] + "[%-30s]" % "#{x[2]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
a = "[%-45s]" % "#{x[0]}"[0..39] + "[%-30s]" % "#{x[3]}"[0..29] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-9s]" % "#{x[1][0]["Unit"]}" +  "[%+4s]" % "#{x[1][0]["Price"]}" 
puts a
tigardconcentratesortbyprice += a + "\n"
end

output = File.open("#{ARGV[0]}SortBy#{ARGV[1]}.txt", "w")
output.puts tigardconcentratesortbyprice
output.close
