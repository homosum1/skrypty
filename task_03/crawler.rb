require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'json'


def search_amazon(keyword, pageCnt)
  encoded = CGI.escape(keyword)
  results = []

    (1..pageCnt).each do |page|
        puts "Pobieranie strony #{page}..."

        url = "https://www.amazon.pl/s?k=#{encoded}&s=price-desc-rank&page=#{page}"

        begin
            html = URI.open(url,
                "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            )
        rescue OpenURI::HTTPError => e
            puts "Error when trying to read: #{page}: #{e.message}"
            next
        end

        doc = Nokogiri::HTML(html)

        items = doc.css('div.s-result-item').select { |item| !item['data-asin'].to_s.strip.empty? }

        results += items.map do |item|
            {
                asin: item['data-asin'],
                title: item.at_css('h2 span')&.text&.strip || "Brak tytułu",
                price: item.at_css('.a-price .a-offscreen')&.text&.strip || "Brak ceny"
            }
        end

        # delay
        sleep(rand(1.0..2.5)) 
    end

    File.open("amazon_results.json", "w") do |file|
        file.write(JSON.pretty_generate(results))
    end

    puts "Data from: #{pageCnt} pages saved to: amazon_results.json"
end

def scrape_amazon_details(asin)
    url = "https://www.amazon.pl/dp/#{asin}"
  
    begin
        html = URI.open(url,
            "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
    rescue OpenURI::HTTPError => e
        puts "Error when loading product: #{asin}: #{e.message}"
        return nil
    end
  
    doc = Nokogiri::HTML(html)
  
    details = {}
  
    doc.css('#productDetails_techSpec_section_1 tr').each do |row|
        key = row.at_css('th')&.text&.strip
        value = row.at_css('td')&.text&.strip
        details[key] = value if key && value
    end
  
    doc.css('#prodDetails tr').each do |row|
        key = row.at_css('td.label')&.text&.strip
        value = row.at_css('td.value')&.text&.strip
        details[key] = value if key && value
    end
  
    info_section = doc.at_css('#feature-bullets')
    if info_section
        bullets = info_section.css('li span').map { |el| el.text.strip }.reject(&:empty?)
        details["Informacje o produkcie"] = bullets
    end
  
    return details
end

def complete_searched_results(inputF, outputF)
    products = JSON.parse(File.read(inputF))
    complete_products = []
  
    products.each_with_index do |product, index|
        asin = product["asin"]
        puts "#{index + 1}/#{products.size} - scraping asin: #{asin}"
    
        details = scrape_amazon_details(asin)
        product["details"] = details || {}
    
        complete_products << product

        sleep(rand(0.3..1))
    end

    puts "saving data to: #{outputF}"
    File.open(outputF, "w") do |file|
        file.write(JSON.pretty_generate(complete_products))
    end

    puts "saving data completed"
end

# UWAGI:
# - dodałem sortowanie po cenie
# - dodałem wybór ilości scrapowanych storn
# - linki przechowywane są jako identyfikatory ASIN (przechowywanie dodatkowych linków byłoby redundantne)

# search_amazon("lego star wars", 3) #(dodałem sortowanie po cenie)
# complete_searched_results("amazon_results.json", "amazon_results_detailed.json")

