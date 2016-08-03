require './setup'

ARGV << "help" if ARGV.empty?
input = ARGV.join(" ")

case input
when "help"
  pp "Here is a list of available commands:"
  p "   new     - Create a new contact"
  p "   list    - List all contacts"
  p "   show    - show a contact by: name or email or an ID"
  p "   update  - Update contact"
  p "   delete  - Delete specified ID"

when "list"
   Contact.all.each do |contact|
     p contact
   end

when "new"
  p "Please provide a full name."
  fullname = STDIN.gets.chomp.split.map{|words| words.capitalize}.join(' ')

  p "Please provide an email."
  email = STDIN.gets.chomp

  contact = Contact.create(name: fullname, email: email)
  p "Your contact has been created with Id: #{contact.id}"

when /(show)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  p Contact.find(id)

when /(delete)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  contact = Contact.find(id)
  puts "Are you sure you'd like to delete #{contact}"
  response = STDIN.gets.chomp
  deleted_contact = contact.destroy if response = "yes"
  p "You have deleted #{deleted_contact}"

when /(name)\s\w+/
  search = /\s\w+/.match(input).to_s.strip
  p Contact.find_by_name(search)

when /(email)\s\w+@\w+\.\w+/
  search = /\s\w+/.match(input).to_s.strip
  p Contact.find_by_email(search)

when /(update)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  contact = Contact.find(id)
  p contact
  p "New name?"
  response = STDIN.gets.chomp
  contact.name = STDIN.gets.chomp.split.map{|words| words.capitalize}.join(' ') if response == "yes"
  p "New email?"
  response = STDIN.gets.chomp
  contact.email = STDIN.gets.chomp if response == "yes"
  binding.pry

  p "Are you ok with?"
  p "Name: #{contact.name} and Email: #{contact.email}"
  response = STDIN.gets.chomp
  contact.save if response == "yes"

else
  nil
end
