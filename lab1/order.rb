#!/usr/bin/ruby
class Order
  attr_accessor :id
  attr_accessor :total
  attr_accessor :cat_id
  attr_accessor :created

  def initialize(id , total, category_id, created)
    @id = id
    @total = total
    @cat_id = category_id
    @created = created
  end

  def show_info
    puts @id.to_s+' '+@total.to_s+' '+@cat_id.to_s+' '+@created
  end
end