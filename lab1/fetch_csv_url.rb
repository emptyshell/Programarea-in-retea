#!/usr/bin/ruby
require 'open-uri'
require 'csv'
require 'net/http'
load 'category.rb'
load('order.rb')


class FetchCsvUrl

  attr_reader :orders_list
  attr_reader :category_list
  attr_accessor :start_date
  attr_accessor :end_date

  @category
  @orders
  @category_list
  @orders_list
  @start_date
  @end_date


  def request_category
    category_url= "https://evil-legacy-service.herokuapp.com/api/v101/categories/"
    uri = URI.parse(category_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri,{'X-API-Key' => '55193451-1409-4729-9cd4-7c65d63b8e76','accept'=>'text/csv'})
    response = http.request(request)
    @category = response.body

  end

  def parse_category
    File.open('category_cache.csv','w') { |file| file.write(@category)}
    category_array = CSV.read('category_cache.csv')
    i = 1
    @category_list = Array.new
    while i < category_array.count do
      @category_list.push(Category.new(category_array[i][0],category_array[i][1],category_array[i][2]))
      i+=1
    end
  end

  def request_orders
    orders_url= "https://evil-legacy-service.herokuapp.com/api/v101/orders/"
    uri = URI.parse(orders_url)
    uri.query = [uri.query, "start="+@start_date].compact.join('?')
    uri.query = [uri.query, "end="+@end_date].compact.join('&')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri,{"X-API-Key" => "55193451-1409-4729-9cd4-7c65d63b8e76",'accept'=>"text/csv"})
    resp = http.request(request)
    @orders = resp.body
  end

  def parse_orders
    File.open('orders_cache.csv','w') { |file| file.write(@orders)}
    orders_array = CSV.read('orders_cache.csv')
    i = 1
    @orders_list = Array.new
    while i < orders_array.count do
      @orders_list.push(Order.new(orders_array[i][0],orders_array[i][1],orders_array[i][2],orders_array[i][3]))
      i+=1
    end
  end
end