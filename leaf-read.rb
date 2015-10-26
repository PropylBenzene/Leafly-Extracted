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
@results.reject! { |y| y[0].include?("Topical")}
@results.reject! { |y| y[0].include?("TOPICAL")}
@results.reject! { |y| y[0].include?("Tinc")}
@results.reject! { |y| y[0].include?("TINC")}
@results.reject! { |y| y[0].include?("Tincture")}
@results.reject! { |y| y[0].include?("Caps")}
@results.reject! { |y| y[0].include?("CAPS")}
@results.reject! { |y| y[0].include?("CAPSULES")}
@results.reject! { |y| y[0].include?("Edible")}
@results.reject! { |y| y[0].include?("Rations")}
@results.reject! { |y| y[0].include?("Preroll")}
@results.reject! { |y| y[0].include?("Pre-roll")}
@results.reject! { |y| y[0].include?("Pre-Roll")}
@results.reject! { |y| y[0].include?("Pre Roll")}
@results.reject! { |y| y[0].include?("Top -")}
@results.reject! { |y| y[0].include?("TOP")}
@results.reject! { |y| y[0].include?("Salve")}
@results.reject! { |y| y[0].include?("Lip Balm")}
@results.reject! { |y| y[0].include?("Joints")}
@results.reject! { |y| y[0].include?("Tailgatorz")}
#@results.reject! { |y| y[0].include?("Caviar")}
@results.reject! { |y| y[0].include?("Soaking Salts")}
@results.reject! { |y| y[0].include?("Lip Buzz")}
@results.reject! { |y| y[0].include?("Battery")}
@results.reject! { |y| y[0].include?("Nana's Naturals")}



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
if ARGV[0] == "Flower"
	units.gsub!("Gram", "1g")
	units.gsub!("Eighth",  "3.5g")
	units.gsub!("Quarter", "7g")
	units.gsub!("Half",  "14g")
	units.gsub!("One",  "28g")
	units.gsub!("1/21g", ".5g")
#Generating Loop for Header, every 46 Lines
#	price.each do |y|
#		a = y.to_i.to_s
#		y = a
#	end
	a = "[%-27s]" % "#{x[0]}"[0..26] + "[%-25s]" % "#{x[3]}"[0..24] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-17s]" % "#{units}"[0..16] + "[%+17s]" % "#{price}" 

elsif ARGV[0] == "Concentrate"

  	units.gsub!("Gram", "1g")
	units.gsub!("Half Gram" "0.5g")
	units.gsub!("HalfGram", "0.5g")
	units.gsub!("Quarter", "7g")
	units.gsub!("Eighth", "3.5g")
	units.gsub!("qt. gram", "0.25g")
	a = "[%-35s]" % "#{x[0]}"[0..34] + "[%-30s]" % "#{x[3]}"[0..29] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-16s]" % "#{units}"[0..15] + "[%+7s]" % "#{price}" 

elsif ARGV[0] == "Clone"
	a = "[%-30s]" % "#{x[0]}"[0..29] + "[%-30s]" % "#{x[3]}"[0..29] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-16s]" % "#{units}"[0..15] + "[%+12s]" % "#{price}" 	

elsif ARGV[0] == "Seeds"
		a = "[%-27s]" % "#{x[0]}"[0..26] + "[%-25s]" % "#{x[3]}"[0..24] + "[%-20s]" % "#{x[2]}"[0..19] + "[%-17s]" % "#{units}"[0..99] + "[%+17s]" % "#{price}" 

end


puts a

if a != nil
	tigardconcentratesortbyprice += a + "\n"
end

puts tigardconcentratesortbyprice

end
if ARGV[0] != "Seeds"
	output = File.open("#{ARGV[0]}sSortBy#{ARGV[1]}.txt", "w")
	output.puts tigardconcentratesortbyprice
	output.close
else
	output = File.open("#{ARGV[0]}SortBy#{ARGV[1]}.txt", "w")
	output.puts tigardconcentratesortbyprice
	output.close
end

output = File.open("#{ARGV[0]}notifications.txt", "w")
output.puts notifications_list_array
output.close
