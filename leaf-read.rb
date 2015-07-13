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
@results = c.zip(d,e) #Combines the name and pricing together 
@results.reject! { |y| y[1][0].nil? }
end

##sorts by price.
Hash[*@names.flatten]
@results.sort_by! do |x|
	x[1][0]["Price"]
end

#Puts the output out.

@results.each do |x|
puts "[%-60s]" % "#{x[0]}" + "[%-30s]" % "#{x[2]}" + "[%-13s]" % "#{x[1][0]["Unit"]}" +  "[%+6s]" % "#{x[1][0]["Price"]}" 
end
