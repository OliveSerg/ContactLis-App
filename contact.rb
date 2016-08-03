require 'csv'
require 'pry'
require 'pg'

ARGV << "help" if ARGV.empty?
input = ARGV.join(" ")
# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  DB = PG.connect({
          host: 'localhost',
          dbname: 'contact_database',
          user: 'development',
          password: 'development'
          })
  TABLE = 'contacts'

  attr_accessor :name, :email
  attr_reader :id

  def initialize(params={})
    @name = params[:name]
    @email = params[:email]
    @id = params[:id]
  end


  def saved?
    !!@id
  end

  def save
    if saved?
      DB.exec_params("UPDATE #{TABLE} SET name=$1, email=$2 WHERE id=$3;", [@name, @email, @id])
    else
      fields = {name: @name, email: @email}
      Contact.create(fields)
    end
  end

  def delete
    return unless saved? # We can only proceed if we have an id
    DB.exec("DELETE from #{TABLE} where id=#{@id};")
    self
  end



  class << self

    def all
      DB.exec("SELECT * from #{TABLE};").map {|contact| instance_from_row(contact)}
    end

    def create(fields)
      if dup_email?(fields[:email])
        result = DB.exec_params(
          "INSERT INTO #{TABLE} (name, email) VALUES ($1, $2) RETURNING id",
          [fields[:name], fields[:email]]
        )
        Contact.new(fields.merge(id: result[0]['id'].to_i))
      end
    end

    def method_missing(method_name, *arguments)
      method_name = method_name.to_s
      arguments = arguments.first
      if method_name == 'find'
        # id = method_name.spilt("_").select {|value| value.is_an_integer?}
        # id = method_name.scan(/\d+/)
        result = DB.exec_params("SELECT * from #{TABLE} where id=$1::int;", [arguments])
        return nil if result.values.empty?
        instance_from_row(result.first)
      elsif /(find_by_)\w+\z/.match(method_name)
        find_by = method_name.split("_").last
        result = DB.exec_params("SELECT * from #{TABLE} where #{find_by} ILIKE $1;", ["%#{arguments}%"])
        return [] if result.values.empty?
        result.map {|contact| instance_from_row(contact)}
      else
        "Method #{method_name} does not exist"
      end
    end

    private

    def instance_from_row(row)
      Contact.new({
        id: row['id'].to_i,
        name: row['name'],
        email: row['email']
      })
    end

    def dup_email?(email)
      match_email = DB.exec_params("SELECT * from #{TABLE} where email=$1::text;", [email])
      match = match_email.select {|contact| contacthas_value?(email)}
      match.empty?
    end

  end
end

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

  contact_details = {name: fullname, email: email}

  contact = Contact.create(contact_details)
  p "Your contact has been created with Id: #{contact.id}"

when /(show)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  p Contact.find(id)

when /(delete)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  contact = Contact.find(id)
  deleted_contact = contact.delete
  p "You have deleted #{deleted_contact}"

when /(show_name)\s\w+/
  search = /\s\w+/.match(input).to_s.strip
  p Contact.find_by_name(search)

when /(show_email)\s\w+@\w+\.\w+/
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

#TODO Impliment a way to input the function youd like to call
# if false
#   p "What would you like to update"
#   response = STDIN.gets.chomp
# end
# def dup_email?(email)
#   match_email = File.open(LIST).readlines do |line|
#     line.split(",").select {|match| match == email }
#   end
#   match_email.include?(email)
# end
#
# def find(file, id)
#   list = Contact.all(file)
#   list = list.select do |value|
#     value if value.split(",").include?(id.to_s)
#   end
#   list = list.first.split(",")
#   if list.any?
#     p "Name: #{list[0]}"
#     p "Email: #{list[1]}"
#     p "Id: #{list[2]}"
#   else
#     p "Not found"
#   end
# end
#
# def search(file, term)
#   list = Contact.all(file)
#   list = list.select do |value|
#     value if value.include?(term)
#   end
#   list = list.map do |value|
#     value.split(",")
#   end
#   if list.any?
#     list.each do |value|
#       p "Name: #{value[0]}"
#       p "Email: #{value[1]}"
#       p "Id: #{value[2]}"
#     end
#   else
#     p "Not found"
#   end
# end
#
# def display_list(file)
#   raise "This is not a csv file" unless file.split(".").last == "csv"
#   File.open(file).readlines.each {|line| p line.chomp}
# end

# def email=(email)
#   list = Contact.all(LIST).select do |value|
#     value if value.include?(email)
#   end
#   list = list.map {|value| value.split(",")}
#   if email == nil || email.size == 0 || email == list[1]
#     p "Duplicate!!"
#   else
#     @email = email
#   end
# end
# Provides functionality for managing contacts in the csv file.
