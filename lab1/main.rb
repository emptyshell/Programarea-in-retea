#!/usr/bin/ruby
load 'agregator.rb'
load 'fetch_csv_url.rb'
load 'category.rb'
load 'order.rb'

class Main
  def load_last_session
    last_session = File.open("session.cache","r") do |file|
      file.each_line do |line|
        puts line
      end
    end
  end

  def print_data
    agregator = Agregator.new
    agregator.start
    session = File.open("session.cache","w") do
      |file|
      i = 0
      while i<agregator.tree.count.to_i do
        puts agregator.tree[i].name.to_s+"         "+ agregator.orders_subtree[agregator.tree[i].id.to_i].to_f.to_s
        file.puts agregator.tree[i].name.to_s+"         "+ agregator.orders_subtree[agregator.tree[i].id.to_i].to_f.to_s
        agregator.category_subtree[i].each {
            |category| puts "     "+category.name.to_s+"            "+ agregator.orders_subtree[category.id.to_i].to_f.to_s
            file.puts "     "+category.name.to_s+"            "+ agregator.orders_subtree[category.id.to_i].to_f.to_s
        }
        i+=1
      end
    end
  end

  def start
    while true do
      self.load_last_session
      self.print_data

      puts "new request? [y/n]"
      input = gets
      if (input == "n\n")
        puts "Goodbye, Have a nice day!"
        break
      end
      system "clear"
    end
  end
end

main = Main.new
main.start