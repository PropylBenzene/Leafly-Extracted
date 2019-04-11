#TODO
# - Insert a check to make sure all duplicates are removed per store search, those staff picks suck.
# - Create an array with all the extensions for the leafly HTML to search, compile top 20 for now.
# - Output to a file somehow.
# - Create a function to sort by price or extractor
# - Convert data pulled to a JSON
# - Create a check to remove cartridges.


require 'nokogiri'
require 'open-uri'
require 'watir'
require 'csv'

@combined, @extractor, @concentrate_name, @quantity, @price, @cannabinoids_content, @dispensaries = [], [], [], [], [], [], []



#Storage Array for Dispensaries to Query
@dispensaries << {:name => "Attis Trading - Barbur", :url => "attis-trading---7737-sw-barbur"} << {:name => "Bridge City - SE", :url => "bridge-city-collective-2"} << {:name => "Nectar - Barbur", :url => "the-pharm-shoppe"} << {:name => "Zion", :url => "zion-cannabis"} << {:name => "Virtue Supply", :url => "virtue-supply-company"} << {:name => "Nectar - Mississippi", :url => "nectar-3"} << {:name => "Botanica - SE 12th", :url => "buckman-cannabis"} << {:name => "Belmont Collective", :url => "belmont-collective"} << {:name => "Brothers - SE Morrison", :url => "brothers-cannabis---morrison"} << {:name => "Gras Cannabis", :url => "gras-cannabis"} << {:name => "Truly Pure", :url => "truly-pure"} << {:name => "Cannablis - Firestation", :url => "cannabliss-portland"} << {:name => "Farma", :url => "farma"} << {:name => "Medigreen", :url => "medigreencollective"} << {:name => "Brothers - Division", :url => "brothers-cannabis-club"} << {:name => "Green Planet - Milwaukie", :url => "the-green-planet---milwaukie"} << {:name => "Attis Trading - Gladstone", :url => "attis-trading-company"} << {:name => "Tetra Cannabis", :url => "tetra-cannabis"} << {:name => "Portland Canna Connection", :url => "canna-connection"} << {:name => "Floyd's Cannabis", :url => "tru-cannabis---28th-ave"} << {:name => "Chalice - Downtown", :url => "chalice-farms-portland-downtown"} << {:name => "Serra - Downtown", :url => "serra-downtown"} << {:name => "Terpene Station", :url => "brooklyn-holding-company"} << {:name => "Pakalolo", :url => "pakalolo"} << {:name => "Botanica - Foster", :url => "botanica-foster-powell"} << {:name => "Amberlight", :url => "amberlight-cannabis-house"} << {:name => "Foster Buds", :url => "foster-buds"} << {:name => "Chalice - Powell", :url => "chalice-farms-powell"} << {:name => "52nd Dispensary", :url => "the-dispensary-on-52nd"} << {:name => "Papa Buds", :url => "papa-buds"} << {:name => "Serra - Belmont", :url => "serra-belmont"} << {:name => "Nectar - Montaville", :url => "nectar---stark"} << {:name => "Nectar - Lents", :url => "nectar---foster"} << {:name => "Mr. Nice Guy", :url => "hicascade"} << {:name => "Budlandia", :url => "budlandia---woodward-st-"} << {:name => "Oregon Grown", :url => "oregon-grown"} << {:name => "Puddletown", :url => "puddletown"} << {:name => "50Trees - East", :url => "five-zero-trees"} << {:name => "Cannablis - BLVD", :url => "cannabliss-89th"} << {:name => "Silver Stem", :url => "silver-stem-fine-cannabis-of-oregon"} << {:name => "TreeHouse Collective", :url => "treehouse-collective"} << {:name => "Happy Leaf", :url => "happy-leaf"} << {:name => "Pure Green", :url => "pure-green"} << {:name => "Refinery", :url => "refinery"} << {:name => "Urban Farmacy", :url => "urban-farmacy-"} << {:name => "Collective Awakenings", :url => "collective-awakenings"} << {:name => "Home Grown Apothecary", :url => "home-grown-apothecary60fa"} << {:name => "Fidus PDX", :url => "fidus-pdx"} << {:name => "Exhale", :url => "exhale-portland"} << {:name => "Little Amsterdam", :url => "little-amsterdam-nevada-st"} << {:name => "Natural RXemedies", :url => "natural-rxemedies"}


width = @dispensaries.count
@ajero = []


for d in 0..(width - 1)

tame = "https://www.leafly.com/dispensary-info/#{@dispensaries[d][:url]}"

@browser = Watir::Browser.new :chrome
@browser.goto(tame)

sleep(2)
@browser.button(:xpath, '//*[@id="tou-continue"]').click
sleep(5)
@browser.element(:xpath, "//label[contains(@class, 'selected concentrate')]").click
sleep(2)

def refresh_html_grab()
puts "Grabbing the Page!\n"
puts @browser.url
@html_doc = Nokogiri::HTML(@browser.html)
puts "Page grabbed"

end


def next_page()
#Select 'Next' Page. Put in check if it exists.
sleep(30)
puts "Onto the next page!\n"
@browser.element(:xpath, "//div[contains(@class, 'arrow-next')]").click
sleep(3)

end


def scrape_it(d)
puts "Clearing variables"
@concentrate_name.clear
@extractor.clear
@quantity.clear
@price.clear
@cannabinoids_content.clear

puts "Beginning Scraping\n"

#Pulls out the concentrate names.
place_holder = @html_doc.xpath("//p[contains(@class, 'desktop-item-name')]")
place_holder.each{|i| @concentrate_name << i.text}
sleep(2)
#Concentrate Extractor
tea_holder = @html_doc.xpath("//span[contains(@class, 'brand-name')]")
tea_holder.each{|i| @extractor << i.text}
sleep(2)

#THC/CBD Content
@cannabinoids_content = @html_doc.xpath("//div[contains(@class, 'item-symbol')]")
#dumps all the texts into an array so it can be sorted to remove characters.
something = []
@cannabinoids_content.each {|item| something << item.text}
something.each do |i|
   if i.count("a-zA-Z") > 0
      something.delete i
   elsif i.empty? == TRUE
	  something.delete i
   end
@cannabinoids_content = []
#output of each THC/CBD percentage an nested array of [x][1or2]
@cannabinoids_content = something.each_slice(2).to_a
end	


#Price Content
something = []
@price = []
@price = @html_doc.xpath("//span[contains(@class, 'primary')]")
puts @price
@price.each {|item| something << item.text}
something.each do |i|
   if i.count("a-zA-Z") > 0
	  something.delete i
   elsif i.empty? == TRUE
	  something.delete i
   end
end
#access via price[x] already in strings and just text
@price = something


#Quantity Content - Access via quantity[x].text
coffee_holder = @html_doc.xpath("//span[contains(@class, 'secondary')]")
coffee_holder.each{|i| @quantity << i.text}

#input a function to remove duplicates and put this all in as a JSON array so it can be compiled per the same shop and then remove duplicate hash entries.
length = (@concentrate_name.count - 1)
puts length
for x in 0..length
#@combined << "Strain: #{@concentrate_name[x]}\tExtractor: #{@extractor[x]}\tTHC: #{@cannabinoids_content[x][0]}\tCBD: #{@cannabinoids_content[x][1]}\tPrice: #{@price[x]}\tQuantity: #{@quantity[x]}\n"
puts "Writing to file!"

output = File.open("somehe5.csv", "a")
output << [@concentrate_name[x], @extractor[x] , @cannabinoids_content[x][0] , @cannabinoids_content[x][1] , @price[x] , @quantity[x], @dispensaries[d][:name]].to_csv


@ajero << [@concentrate_name[x], @extractor[x] , @cannabinoids_content[x][0] , @cannabinoids_content[x][1] , @price[x] , @quantity[x], @dispensaries[d][:name]].to_csv

#output << @ajero
puts @ajero
@ajero.clear


#puts @dispensaries[d][:name]
#holder = "#{@concentrate_name[x]}\t#{@extractor[x]}\t#{@cannabinoids_content[x][0]}\t#{@cannabinoids_content[x][1]}\t#{@price[x]}\t#{@quantity[x]}\n"
#@combined << holder.to_s
end

#CSV.open("something.csv", "a") {|csv| csv << @combined}
puts @dispensaries[d][:name]
end

refresh_html_grab()

sleep (5)
hero = @html_doc.xpath("//span[contains(@class, 'paging')]")
loop = hero.last.text.to_i

for r in 0..(loop- 1)
sleep(30)
scrape_it(d)


sleep(30)
if r == (loop -1)
   @browser.close
   break
elsif @browser.element(:xpath, "//div[contains(@class, 'arrow-next')]").visible? == TRUE
   next_page()
else
   @browser.close
   break
end
sleep(30)
refresh_html_grab()
sleep(5)
puts r

sleep(30)
end
end