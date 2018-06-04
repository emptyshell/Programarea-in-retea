#!/usr/bin/ruby
load 'fetch_csv_url.rb'
load 'category.rb'
load 'order.rb'
require 'thread'
require 'bigdecimal'
require 'date'


class Agregator
  attr_accessor :tree
  attr_accessor :orders_subtree

  @tree
  @orders_subtree
  @fetch
  @category_map

  def initialize
    @tree = Array.new
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

    thr1 = Thread.new do
      @fetch.request_category
      @fetch.parse_category
    end
    thr2 = Thread.new do
      @fetch.request_orders
      @fetch.parse_orders
    end
    thr1.join
    thr2.join
  end

  def create_category_map
    cat_list = @fetch.category_list
    @category_map = Array.new(cat_list.count) {Array.new}
    i = 1
    while i < @category_map.count do
      j = 1
      while j < cat_list.count do
        if cat_list[j].cat_id.to_i == i.to_i
          @category_map[i].push(cat_list[j])
        end
        j+=1
      end
      i+=1
    end
  end

  def find_root_category
    @tmp = Array.new
    cat_list = @fetch.category_list
    i = 0
    while i<cat_list.count do
      if cat_list[i].cat_id == nil
        @tmp.push(cat_list[i].id.to_i)
      end
      i+=1
    end
  end

  def create_category_tree
    self.find_root_category
    cat_list = @fetch.category_list
    @tree = Array.new(@tmp.count) {Array.new}
    #push root categories first
    i = 0
    while i < @tmp.count do
      j = 0
      while j < cat_list.count do
        if @tmp[i].to_i == cat_list[j].id.to_i
          @tree[i].push(cat_list[j])
        end
        j+=1
      end
      i+=1
    end
  end

  def create_subtree (id)
    i = 0
    while i < @tree.count do
      k=0
      @tree[i].each_with_index {|line,index |
        if line.class.to_s == "Category"
          if line.id.to_i == id
            k=index
            break
          end
        end
        }
      if @tree[i][k].id.to_i == id
        j = 0
        if @category_map[id.to_i] != nil
          while j < @category_map[id.to_i].count do
            if k != 0 && @tree[i][k].class.to_s != "Array"
              t = @tree[i][k]
              @tree[i][k] = Array.new
              @tree[i][k].push(t)
              @tree[i][k].push(@category_map[id.to_i][j])
            elsif k != 0 && @tree[i][k].class.to_s == "Array"
              @tree[i][k].push(@category_map[id.to_i][j])
            else
              @tree[i].push(@category_map[id.to_i][j])
            end
            if @category_map[@category_map[id.to_i][j].id.to_i] != nil
              self.create_subtree(@category_map[id.to_i][j].id.to_i)
            end
            j+=1
          end
        end
      end
      i+=1
    end
  end

  def calc_totals
    cat_list = @fetch.category_list
    ord_list = @fetch.orders_list
    @orders_subtree = Array.new(cat_list.count.to_i+1,BigDecimal.new("0"))
    i=1
    while i<ord_list.count.to_i do
      total = BigDecimal.new(ord_list[i].total)
      @orders_subtree[ord_list[i].cat_id.to_i] += total
      i+=1
    end
    i=0
    while i<@category_map.count.to_i do
      total = BigDecimal.new("0")
      @category_map[i].each_with_index {|line,index |
        if @category_map[line.id.to_i].class.to_s == "Array"
          @category_map[line.id.to_i].each {
              |category| total += @orders_subtree[category.id.to_i]
          }
          @orders_subtree[line.id.to_i] += total
        end
      }
      i+=1
    end
  end

  #main thread that will control 2 sub threads
  def start
    mutex = Mutex.new
    cv = ConditionVariable.new
    main_thread = Thread.new do
      self.ask_perioud
      self.create_category_map
      self.create_category_tree
      @tmp.each do
        |root| Thread.new do
            self.create_subtree(root.to_i)
        end
      end.join
      totals_thr = Thread.new do
        self.calc_totals
      end.join
    end.join
    #sleep 5
    mutex.lock
  end
end