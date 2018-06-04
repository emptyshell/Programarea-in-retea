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
      #puts agregator.tree.inspect
      #agregator.orders_subtree.each_with_index {|line,index| puts index.to_s+" "+line.to_f.to_s}
      while i<agregator.tree.count.to_i do
        agregator.tree[i].each_with_index  {
          |elem,index|
          if elem.class.to_s == "Category" && index == 0
            puts elem.name.to_s+"         "+ agregator.orders_subtree[elem.id.to_i].to_f.to_s
            file.puts elem.name.to_s+"         "+ agregator.orders_subtree[elem.id.to_i].to_f.to_s
          elsif elem.class.to_s == "Category" && index > 0
            puts "     "+elem.name.to_s+"         "+ agregator.orders_subtree[elem.id.to_i].to_f.to_s
            file.puts "     "+elem.name.to_s+"         "+ agregator.orders_subtree[elem.id.to_i].to_f.to_s
          elsif elem.class.to_s == "Array"
            elem.each_with_index {|line, i|
              if  i == 0
                puts "     "+line.name.to_s+"         "+ agregator.orders_subtree[line.id.to_i].to_f.to_s
                file.puts "     "+line.name.to_s+"         "+ agregator.orders_subtree[line.id.to_i].to_f.to_s
              else
                puts "          "+line.name.to_s+"         "+ agregator.orders_subtree[line.id.to_i].to_f.to_s
                file.puts "          "+line.name.to_s+"         "+ agregator.orders_subtree[line.id.to_i].to_f.to_s
              end

            }
          end
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
      if input == "n\n" || input == "N\n" || input == "no\n" || input == "No\n" || input == "NO\n"
        puts "Goodbye, Have a nice day!"
        break
      end
      system "clear"
    end
  end
end

main = Main.new
main.start