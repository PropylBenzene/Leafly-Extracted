#TODO
# - Insert a check to make sure all duplicates are removed per store search, those staff picks suck.
# - Pricing function sucks. The lack of pricing and the duplication in some of the pulls is hard to work with. Must fund a better way of patching that. - DONE
# - Create an array with all the extensions for the leafly HTML to search, compile top 20 for now.
# - Output to a file somehow. - DONE
# - Create a function to sort by price or extractor - This will be implemented in the Rails front end. compiling into an EXcel allows for sorting for now.
# - Include a function to put time stamp from when the menu was last updated per dispensary.
# - Include a check to change the price to what it would be with tax when it is known as being without tax.
# - Create special marking for those that display WITH tax.
# - Input change in prices for specials when they are happening (Nectar) Wax Wed, Shatterday, etc.
# - Convert data pulled to a JSON
# - Create a check to remove cartridges.
# - BOTANICA forces exit when onto the next page, edit. - DONE This was fixed with a .to_s at line 121
#Nectars/Belmont Collective have issues where they print double pricing per item. I need to correct this with a .contains on nectars and removing the third pricing. - DONE This was fixed with the check forwards and backwards, but needs more investigation.
# - Some sites have medical pricing and rec pricing, begin invesitgation into how to handle that.
# - Put in a map for pulling the quantity with the item scraped.


require 'nokogiri'
require 'open-uri'
require 'watir'
require 'csv'
require 'pry'
require 'colorize'

@dispensaries_list = []
@concentrate_name, @extractor_name, @price, @cannabinoids_content, @output = [], [], [], [], [], []
@file_time = Time.now.to_i


# Botanica - Foster/Powell does not have a menu, remove it.
#Storage Array for Dispensaries to Query, exits on Belmont Collective Second Page.
@dispensaries_list << {:name => "Terpene Station", :url => "brooklyn-holding-company"} << {:name => "Pakalolo", :url => "pakalolo"} << {:name => "Amberlight", :url => "amberlight-cannabis-house"} << {:name => "Foster Buds", :url => "foster-buds"} << {:name => "Chalice - Powell", :url => "chalice-farms-powell"} << {:name => "52nd Dispensary", :url => "the-dispensary-on-52nd"} << {:name => "Papa Buds", :url => "papa-buds"} << {:name => "Serra - Belmont", :url => "serra-belmont"} << {:name => "Nectar - Montaville", :url => "nectar---stark"} << {:name => "Nectar - Lents", :url => "nectar---foster"} << {:name => "Mr. Nice Guy", :url => "hicascade"} << {:name => "Budlandia", :url => "budlandia---woodward-st-"} << {:name => "Oregon Grown", :url => "oregon-grown"} << {:name => "Puddletown", :url => "puddletown"} << {:name => "50Trees - East", :url => "five-zero-trees"} << {:name => "Cannablis - BLVD", :url => "cannabliss-89th"} << {:name => "Silver Stem", :url => "silver-stem-fine-cannabis-of-oregon"} << {:name => "TreeHouse Collective", :url => "treehouse-collective"} << {:name => "Happy Leaf", :url => "happy-leaf"} << {:name => "Pure Green", :url => "pure-green"} << {:name => "Refinery", :url => "refinery"} << {:name => "Urban Farmacy", :url => "urban-farmacy-"} << {:name => "Collective Awakenings", :url => "collective-awakenings"} << {:name => "Home Grown Apothecary", :url => "home-grown-apothecary60fa"} << {:name => "Fidus PDX", :url => "fidus-pdx"} << {:name => "Exhale", :url => "exhale-portland"} << {:name => "Little Amsterdam", :url => "little-amsterdam-nevada-st"} << {:name => "Natural RXemedies", :url => "natural-rxemedies"}

#{:name => "Nectar - Barbur", :url => "the-pharm-shoppe"} << {:name => "Nectar - Mississippi", :url => "nectar-3"} << {:name => "Botanica - SE 12th", :url => "buckman-cannabis"} << {:name => "Belmont Collective", :url => "belmont-collective"} <<

#<< {:name => "Nectar - Barbur", :url => "the-pharm-shoppe"} << {:name => "Nectar - Mississippi", :url => "nectar-3"} << {:name => "Belmont Collective", :url => "belmont-collective"} << {:name => "Attis Trading - Barbur", :url => "attis-trading---7737-sw-barbur"} << {:name => "Bridge City - SE", :url => "bridge-city-collective-2"} <<  {:name => "Zion", :url => "zion-cannabis"} << {:name => "Virtue Supply", :url => "virtue-supply-company"} << {:name => "Brothers - SE Morrison", :url => "brothers-cannabis---morrison"} << {:name => "Gras Cannabis", :url => "gras-cannabis"} << {:name => "Truly Pure", :url => "truly-pure"} << {:name => "Cannablis - Firestation", :url => "cannabliss-portland"} << {:name => "Farma", :url => "farma"} << {:name => "Medigreen", :url => "medigreencollective"} << {:name => "Brothers - Division", :url => "brothers-cannabis-club"} << {:name => "Green Planet - Milwaukie", :url => "the-green-planet---milwaukie"} << {:name => "Attis Trading - Gladstone", :url => "attis-trading-company"} << {:name => "Tetra Cannabis", :url => "tetra-cannabis"} << {:name => "Portland Canna Connection", :url => "canna-connection"} << {:name => "Floyd's Cannabis", :url => "tru-cannabis---28th-ave"} << {:name => "Chalice - Downtown", :url => "chalice-farms-portland-downtown"} << {:name => "Serra - Downtown", :url => "serra-downtown"} <<

dispensary_count = @dispensaries_list.count

def go_to_homepage(i)

dispensary_url = "https://www.leafly.com/dispensary-info/#{@dispensaries_list[i][:url]}"
#dispensary_url = "https://www.leafly.com/dispensary-info/belmont-collective"

@browser = Watir::Browser.new :chrome, url: "http://localhost:4444/wd/hub"
@browser.goto(dispensary_url)

sleep(2)
@browser.button(:xpath, '//*[@id="tou-continue"]').click
sleep(5)
@browser.element(:xpath, "//label[contains(@class, 'selected concentrate')]").click
sleep(2)

end

def refresh_html_grab()

#Grabs the currently displayed page's HTML and marks it up via Nokogiri
puts "Grabbing the Page!\n"
#puts @browser.url
@html_doc = Nokogiri::HTML(@browser.html)
puts "Page grabbed"

end


def next_page()

#Select 'Next' Page. Put in check if it exists.
sleep(10)
puts "Onto the next page!\n"
begin
	@browser.element(:xpath, "//div[contains(@class, 'arrow-next')]").click
rescue
	#binding.pry
end
sleep(3)

end

def scrape_it(i)

puts "Clearing the variables."

@concentrate_name = []
@extractor_name = []
@cannabinoids_content = []
@price = []
@temp_storage = []

#Scrapes the data on the page.
puts "Beginning Scraping\n"

#Accessible via @concentrate_name[x].text ; this does not require any special formatting.
@concentrate_name = @html_doc.xpath("//p[contains(@class, 'desktop-item-name')]")
puts "Wax Scraped"

#Accessible via @extractor_name[x].text ; this does not require any special formatting.
@extractor_name = @html_doc.xpath("//span[contains(@class, 'brand-name')]")

#THC/CBD Content ; this is now properly formatted.

@cannabinoids_content = @html_doc.xpath("//div[contains(@class, 'item-symbol')]")
@cannabinoids_content.each {|x| @temp_storage << x.text}
@cannabinoids_content = []
#output of each THC/CBD percentage an nested array of [x][1or2]
@cannabinoids_content = @temp_storage.each_slice(3).to_a

puts "Content Scraped"

@temp_storage = []
@price = @html_doc.xpath("//span[contains(@class, 'primary')]")

#binding.pry

@hero_test = File.open("record.txt+#{@file_time}", 'a')
@price.each {|x| @hero_test << x.text + "\t" + @dispensaries_list[i][:name] + "\n"}

@price.each {|item| @temp_storage << item.text}




@temp_storage.each_with_index do |item, index|
	if item.include?("from") && item == @temp_storage[index+1]
		puts "#{item} #{index} BROKE"
		@temp_storage.insert(index+1, "$0")
		puts "#{item} #{index}"
	elsif item.include?("$") && @temp_storage[index+1].to_s.include?("$") 
		puts "#{item} #{index} BROKE"
		@temp_storage.delete_at(index+1)
		puts "#{item} #{index}"	
	elsif item.include?("$") && @temp_storage[index-1].include?("$")
		puts "#{item} #{index} BROKE"
		@temp_storage.delete_at(index)
		puts "#{item} #{index}"
	else
		puts "#{item} #{index} Good"
	end
end

@temp_storage.reject!{|e| e.include? "from "}
		

@price = @temp_storage
#output of each THC/CBD percentage an nested array of [x][1]
#@price = @temp_storage.each_slice(2).to_a

end

@price = @temp_storage



def pretty_arrange(i)

puts "Hello."

#puts @concentrate_name.text

length = (@concentrate_name.count - 1)
#binding.pry


for x in 0..length

@output << [@concentrate_name[x].text, @extractor_name[x].text , @cannabinoids_content[x][0] , @cannabinoids_content[x][1] , @price[x], @dispensaries_list[i][:name]].to_csv

output = File.open("#{@file_time}.csv", "a")
output << [@concentrate_name[x].text, @extractor_name[x].text , @cannabinoids_content[x][0] , @cannabinoids_content[x][1] , @price[x], @dispensaries_list[i][:name]].to_csv

end

#binding.pry
puts @output
@output = []

end



for i in 0..(dispensary_count -1)
go_to_homepage(i)
refresh_html_grab()

#This function can crash and destroy the loop if the 'last' does not convert to a text, caust it's a null value. Need to insert a loop (Zion Cannabis, I'm looking at you) to either rescue this or set the page-count to an automatic of 1. - Solved

begin
	pages = @html_doc.xpath("//span[contains(@class, 'paging')]")
	page_count = pages.last.text.to_i
rescue
	page_count = 1
end

puts "Page Count: #{page_count}"

for p in 0..(page_count -1)

	puts "P: #{p}"
	sleep(3)
	refresh_html_grab()
begin		
	scrape_it(i)
	#binding.pry
	sleep(5)
	pretty_arrange(i)
	sleep(10)
	next_page()
	sleep(3)
rescue
	binding.pry
	@browser.close
	next i
end
end
@browser.close
end
