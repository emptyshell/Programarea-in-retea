require 'net/smtp'
require 'net/imap'
require 'date'
require 'launchy'
require 'thread'

#MAIL SERVER HERE
IMAP_MAIL_SERVER = 'imap.gmail.com'
SMTP_MAIL_SERVER = 'smtp.gmail.com'

# Credentials
USERNAME='valentin.suruceanu@gmail.com'
PASSWORD='B10m3c@n1c@'


class Main

  def initialize

  end

  def read_folders
    imap = Net::IMAP.new(IMAP_MAIL_SERVER,993,true,nil,false)
    imap.authenticate('PLAIN', USERNAME, PASSWORD)
    all_folders = imap.list('*', '*')
     for i in 1..all_folders.count
       if all_folders[i] != nil
         puts all_folders[i].name
       end
     end
  end

  def read (mailbox,key, count)
    i=1
    imap = Net::IMAP.new(IMAP_MAIL_SERVER,993,true,nil,false)
    imap.authenticate('PLAIN', USERNAME, PASSWORD)
    imap.select(mailbox)
    message_id = imap.search([key])
    puts "TOTAL EMAILS FOUND: #{message_id.count}\t"
    j=0
    for i in (message_id.count-1).downto(message_id.count-count)
      envelope = imap.fetch(message_id[i],"ENVELOPE")[0].attr["ENVELOPE"]
      puts "#{j+=1}\t#{envelope.from[0].name}: \t#{envelope.subject} \t#{envelope.date} \t#{envelope.sender[0].name}@#{envelope.sender[0].host}"
    end
    while true
    puts "1.Open an email\n2.Go to previous menu"
    x=gets.chomp
    case x
      when "1"
      puts "Enter the number of email you want to open [eg. 1]: "
      n = gets.chomp
      current_email = imap.fetch(message_id[message_id.count-n.to_i],"BODY[TEXT]")[0].attr["BODY[TEXT]"]
      File.open("index.html",'w') {
        |file| file.write("#{current_email}")
      }
      Launchy.open("/home/valentin/RubymineProjects/mailClient/index.html")
      when "2"
        break
      else
    end
      end
  end

  def send (to,subject,body)
    message = <<END_OF_MESSAGE
From: Valentin Suruceanu <#{USERNAME}>
To: <#{to}>
Subject: #{subject.to_s}
Date: #{Date.today.to_s}
Message-Id: <unique.message.id.string@example.com>

#{body}
END_OF_MESSAGE
    smtp= Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls_auto
    #smtp.enable_ssl
    smtp.start(SMTP_MAIL_SERVER, USERNAME, PASSWORD, :login) do
      smtp.send_message(message, USERNAME, to)
    end
  end

  def send_html (to,subject,body)
    message = <<END_OF_MESSAGE
From: Valentin Suruceanu <#{USERNAME}>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: #{subject.to_s}
Date: #{Date.today.to_s}
Message-Id: <unique.message.id.string@example.com>

#{body}
END_OF_MESSAGE
    smtp= Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls_auto
    #smtp.enable_ssl
    smtp.start(SMTP_MAIL_SERVER, USERNAME, PASSWORD, :login) do
      smtp.send_message(message, USERNAME, to)
    end
  end

  def send_attach (to, subject, body, attachment)
    attach_content = File.read(attachment)
    encodedcontent = [attach_content].pack("m") #base64
    marker = "AUNIQUEMARKER"
    part1 = <<EOF
From: Valentin Suruceanu <#{USERNAME}>
To: <#{to}>
Subject: #{subject.to_s}
MIME-Version: 1.0
Content-type: multipart/mixed; boundary = #{marker}
--#{marker}
EOF
    part2 = <<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit
#{body}
EOF
    part3=<<EOF
Content-Type: multipart/mixed; name = \"#{attachment}\"
Content-Transfer-Enconding:base64
Content-Disposition: attachment; filename = "#{attachment}"
#{encodedcontent}
--#{marker}--
EOF
mailtext = part1+part2+part3
    smtp= Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls_auto
    #smtp.enable_ssl
    smtp.start(SMTP_MAIL_SERVER, USERNAME, PASSWORD, :login) do
      smtp.send_message(mailtext, USERNAME, to)
    end
  rescue Exception => e
    print "Exception oucured: "+ e
  end

  def start_app
    queue = Queue.new
    send_thread = Thread.new do
        if !queue.empty?
          send queue.pop,queue.pop,queue.pop
        end
    end
    puts "CONNECTED ass: \t#{USERNAME}\n"
    while true
      puts "\tMENU\t\n1.Read emails\n2.Send Email\n3.EXIT"
    n=gets.chomp
    case n
      when "1"
        puts "CURRENT MAILBOXES:"
        read_folders
        puts "Choose a Mailbox to read: [eg. INBOX]"
        mailbox = gets.chomp
        puts "Choose key: [ALL/UNSEEN/SEEN]: "
        key = gets.chomp
        puts "Choose number of emails to display[eg. 1]: "
        count = gets.chomp.to_i
        read mailbox,key,count
      when "2"
        while true
        puts "1.Plain email\n2.Html email\n3.Email with attachment\n4.Go to previous menu"
        nn=gets.chomp
        case nn
          when "1"
            puts "Send to:"
            to = gets.chomp
            puts "Subject:"
            subject = gets.chomp
            puts "Message:"
            message = gets.chomp
            send to,subject,message
          when "2"
            puts "Send to:"
            to = gets.chomp
            puts "Subject:"
            subject = gets.chomp
            puts "Message:"
            message = gets.chomp
            send_html to,subject,message
          when "3"
            puts "Send to:"
            to = gets.chomp
            puts "Subject:"
            subject = gets.chomp
            puts "Message:"
            message = gets.chomp
            puts "Attachment [path to file]:"
            path = gets.chomp
            send_attach to,subject,message,path
          when "4"
            break
        end
        end
      when "3"
        break
    end
    end

  end
end

main = Main.new
main.start_app
