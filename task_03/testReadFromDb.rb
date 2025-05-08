require 'sequel'
require 'json'

DB = Sequel.sqlite("amazon_products.db")

products = DB[:products]

lego_products = products.where(price: 'Brak ceny').all
puts "Products without price: #{lego_products.size}"