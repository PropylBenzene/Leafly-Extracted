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
@d = []
@thing = []
@some = []
@table_array.each do |x|
@parsed_data = igor.db("#{x[0]}").table("#{x[1]}").run(cellar)
@temp = @parsed_data.to_a
isolate_concentrate = JsonPath.new('$.[?(@.type == "#{ARGV[0]}")]')
@formatted_data = isolate_concentrate.on(@temp)
puts @formatted_data
@compiled += @formatted_data
c = @compiled.each.map {|x| x["name"]}
@d = @compiled.each.map {|x| x["pricing"]} # Need to do a .each here to do the different units of pricing.
con = @d.each.each.map {|x| x.each.map {|y| y["Price"]}}
tor = @d.each.each.map {|x| x.each.map {|y| y["Unit"]}}
@d = con
e = @compiled.each.map {|x| x["Store"]}
f = @compiled.each.map {|x| x["description"]}
@results = c.zip(@d,e,f,tor) #Combines the name and pricing together 
@results.reject! { |y| y[1].nil? }
@results.reject! { |y| y[1].empty? }

if ARGV[2] != nil
	@results.reject! { |y| y[1][0]["Price"] > ARGV[2].to_i }
#	@results.reject! { |y| y[2][0]["Unit"] != "Gram" }
end
end

notifications_list_array = ""
@results.each do |x|
	b = "#{x[0]}" + "\t" + "#{x[2]}"
	notifications_list_array += b + "\n"
end

if ARGV[0] == "Flower"
	@results.each do |x|

		if x[0].include?("(") == true
			x[0].gsub!(/(?<=\().+?(?=\))/, "")
			x[0].gsub!("() ", "")
			x[0].gsub!("()", "")
		end

		if x[0][0] == "\$"
			for i in 0..8
				x[0][0] = ""
			end
		x[0][0] = ""
		end

		if x[0][0] == " "
			x[0][0] = ""
		end
	end
end
##sorts by ARGV[1].
Hash[*@names.flatten]

if ARGV[1].downcase == "price"
	@results.sort_by! do |x|
	x[1][0]
	end
elsif 
	ARGV[1].downcase == "name"
	@results.sort_by! do |x|
	x[0]
	end
end

#Puts the output out.
units = ""
tigardconcentratesortbyprice = ""
@results.each do |x|

if x[3] != nil
	x[3].gsub!("\n", " ")
	x[3].gsub!("   ", " ")
	x[3].gsub!("\t", " ")
end
units = x[4].join("|")
price = x[1].join("|")
a = "[%-45s]" % "#{x[0]}"[0..39] + "[%-30s]" % "#{x[3]}"[0..29] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-30s]" % "#{units}"[0..29] + "[%+22s]" % "#{price}" 
puts a
tigardconcentratesortbyprice += a + "\n"

end

output = File.open("#{ARGV[0]}SortBy#{ARGV[1]}.txt", "w")
output.puts tigardconcentratesortbyprice
output.close

output = File.open("#{ARGV[0]}notifications.txt", "w")
output.puts notifications_list_array
output.close
