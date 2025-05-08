require 'sequel'
require 'json'

DB = Sequel.sqlite("amazon_products.db")

DB.create_table? :products do
    primary_key :id
    String :asin, unique: true
    String :title
    String :price
    String :brand
    String :material
    String :color
    String :educational_goal
    Integer :pieces_count
    String :theme
    String :character
    String :additional_brand
    String :special_features
    String :product_description, text: true
end

products = DB[:products]

data = JSON.parse(File.read("amazon_results_detailed.json"))
  
data.each do |item|
    details = item["details"] || {}
  
    products.insert_conflict(:replace).insert(
        asin: item["asin"],
        title: item["title"],
        price: item["price"],
        brand: details["Marka"],
        material: details["Materiał"],
        color: details["Kolor"],
        educational_goal: details["Cel edukacyjny"],
        pieces_count: details["Liczba sztuk"]&.to_i,
        theme: details["Motyw"],
        character: details["Postać z kreskówki"],
        additional_brand: details["Marka dodatkowa"],
        special_features: details["Funkcja specjalna"],
        product_description: details["Informacje o tym produkcie"]
    )
end
  