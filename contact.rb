require 'csv'
require 'pry'

ARGV << "help" if ARGV.empty?
input = ARGV.join(" ")
# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact
  LIST = "contact_list.csv"
  attr_accessor :name, :email

  def initialize(name, email, id)
    # TODO: Assign parameter values to instance variables.
    @name = name
    self.email = email
    @id = id
  end

  def email=(email)
    list = Contact.all(LIST)
    list = list.select do |value|
      value if value.include?(email)
    end
    list = list.map do |value|
      value.split(",")
    end
    if email == nil || email.size == 0 || email == list[1]
      p "Duplicate!!"
    else
      @email = email
    end
  end
  # Provides functionality for managing contacts in the csv file.
  class << self

    def all(file)
      File.open(file).readlines.map {|line| line.chomp}
    end

    def dup_email?(email)
      match_email = File.open(LIST).readlines do |line|
        line.split(",").select {|match| match == email }
      end
      match_email.include?(email)
    end

    def create(name, email, phone_number, id)
      unless dup_email?(email)
        Contact.new(name, email, phone_number, id)
        File.open(LIST, "a") {|file| file.puts name + "," + email + "," + id.to_s}
    end

    def find(file, id)
      list = Contact.all(file)
      list = list.select do |value|
        value if value.split(",").include?(id.to_s)
      end
      list = list.first.split(",")
      if list.any?
        p "Name: #{list[0]}"
        p "Email: #{list[1]}"
        p "Id: #{list[2]}"
      else
        p "Not found"
      end
    end

    def search(file, term)
      list = Contact.all(file)
      list = list.select do |value|
        value if value.include?(term)
      end
      list = list.map do |value|
        value.split(",")
      end
      if list.any?
        list.each do |value|
          p "Name: #{value[0]}"
          p "Email: #{value[1]}"
          p "Id: #{value[2]}"
        end
      else
        p "Not found"
      end
    end

    def display_list(file)
      raise "This is not a csv file" unless file.split(".").last == "csv"
      File.open(file).readlines.each {|line| p line.chomp}
    end

  end

end

case input
when "help"
  pp "Here is a list of available commands:"
  p "   new     - Create a new contact"
  p "   list    - List all contacts"
  p "   show    - show a contact"
  p "   search  - Search contacts"
when "list"
  Contact.display_list("contact_list.csv")
when "new"
  p "Please provide a full name."
  fullname = STDIN.gets.chomp.split.map{|words| words.capitalize}.join(' ')

  p "Please provide an email."
  email = STDIN.gets.chomp

  file = File.open("contact_list.csv") do |file|
    file.readlines.each_with_index {|line, index| index if file.eof?}
  end

  id = file.length + 1
  Contact.create(fullname, email, id)
  p "Your contact has been created with Id: #{id}"
when /(show)\s\d+/
  id = /\d+/.match(input).to_s.to_i
  Contact.find("contact_list.csv", id)
when /(search)\s\w+/
  search = /\s\w+/.match(input).to_s.strip
  Contact.search("contact_list.csv", search)
else
  nil
end
