#!/usr/bin/ruby
class Category
  attr_accessor :id
  attr_accessor :name
  attr_accessor :cat_id

  def initialize (id, name, category_id)
    @id = id
    @name = name
    @cat_id = category_id
  end

  def show_info
    puts @id.to_s+' '+@name.to_s+' '+@cat_id.to_s
  end

  def show_names
    puts @name
  end
end