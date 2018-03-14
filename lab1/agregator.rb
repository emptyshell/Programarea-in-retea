#!/usr/bin/ruby
load 'fetch_csv_url.rb'
load 'category.rb'
load 'order.rb'
require 'thread'
require 'bigdecimal'
require 'date'


class Agregator
  attr_accessor :tree
  attr_accessor :category_subtree
  attr_accessor :orders_subtree

  @tree
  @category_subtree
  @orders_subtree
  @fetch

  def initialize
    @tree = Array.new
    @category_subtree =Array.new
  end

  def ask_perioud
    @fetch = FetchCsvUrl.new
    while true do
      puts "Start date [YYYY-MM-DD]: "
      @fetch.start_date = gets
      format_ok = @fetch.start_date.match(/\d{4}-\d{2}-\d{2}/)
      parseable = Date.strptime(@fetch.start_date, '%Y-%m-%d') rescue false

      if  format_ok && parseable
        puts "Start date is valid"
        break
      else
        puts "Start date is not valid"
        next
      end
    end
    while true do
      puts "End date [YYYY-MM-DD]: "
      @fetch.end_date = gets
      format_ok = @fetch.end_date.match(/\d{4}-\d{2}-\d{2}/)
      parseable = Date.strptime(@fetch.end_date, '%Y-%m-%d') rescue false

      if format_ok && parseable
        puts "End date is valid"
        break
      else
        puts "End date is not valid"
        next
      end
    end


    @fetch.request_category
    @fetch.parse_category
    @fetch.request_orders
    @fetch.parse_orders
  end

  #main thread that will control 2 sub threads
  def start
    self.ask_perioud
    cat_list = @fetch.category_list
    ord_list = @fetch.orders_list
    main_thread = Thread.new do
      i = 0
      while i<cat_list.count do
        if cat_list[i].cat_id == nil
          @tree.push(cat_list[i])
        end
        i+=1
      end
    end
    main_thread.join
    category_sort = Thread.new do
      @category_subtree = Array.new(@tree.count+1) {Array.new}
      i = 0
      while i<@tree.count do
        j=0
        while j<cat_list.count do
          if @tree[i].id == cat_list[j].cat_id
            @category_subtree[i].push(cat_list[j])
          end
          j+=1
        end
        i+=1
      end
    end
    orders_sort = Thread.new do

      @orders_subtree = Array.new(cat_list.count.to_i+1,BigDecimal.new("0"))
      i=1
      while i<ord_list.count.to_i do
        total = BigDecimal.new(ord_list[i].total)
        @orders_subtree[ord_list[i].cat_id.to_i] += total
        i+=1
      end
    end
    category_sort.join
    orders_sort.join
    main_category_totals = Thread.new do
      i=1
      while i<@tree.count.to_i do
        total = BigDecimal.new("0")
        @category_subtree[i].each {
            |category| total += @orders_subtree[category.id.to_i]
        }
        @orders_subtree[@tree[i].id.to_i] += total
        i+=1
      end
    end
    main_category_totals.join
  end
end