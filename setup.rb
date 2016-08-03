require 'pry'
require 'active_record'
require_relative './contact_ar.rb'

ActiveRecord::Base.logger = Logger.new(STDOUT)

puts "GETTING FIRED UP!!!!....."
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  encoding: 'unicode',
  pool: 5,
  database: 'contact_database',
  username: 'development',
  password: 'development',
  host: 'localhost',
  port: 5432,
  min_messages: 'error'
)

puts "WE'RE IN!!"
puts "Setting up stuff you need~~"
if !ActiveRecord::Base.connection.table_exists?(:contacts)
  ActiveRecord::Schema.define do
  # drop_table :contacts, force: :cascade if ActiveRecord::Base.connection.table_exists?(:contacts)

    create_table :contacts do |contact|
      contact.column :name, :string
      contact.column :email, :string
      contact.timestamps null: false
    end
  end
end

puts "Done done!!"
