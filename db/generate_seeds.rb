require "faker"
require "date"
require "csv"

# we already provide a filled out media_seeds.csv file, but feel free to
# run this script in order to replace it and generate a new one
# run using the command:
# $ ruby db/generate_seeds.rb
# if satisfied with this new media_seeds.csv file, recreate the db with:
# $ rails db:reset
# doesn't currently check for if titles are unique against each other

CSV.open("db/media_seeds.csv", "w", :write_headers => true,
                                    :headers => ["category", "title", "creator", "publication_year", "description", "user_id"]) do |csv|
  25.times do
    category = %w(album book).sample
    title = Faker::Coffee.blend_name
    creator = Faker::Name.name
    publication_year = rand(Date.today.year - 100..Date.today.year)
    description = Faker::Lorem.sentence
    user_id = rand(1..10)

    csv << [category, title, creator, publication_year, description, user_id]
  end
end

CSV.open("db/users_seeds.csv", "w", :write_headers => true,
         :headers => ["username",  "uid", "provider", "email"]) do |csv|
  10.times do
    name = Faker::Name.name
    uid = "#{rand(10000000..99999999)}"
    provider = "github"
    email = Faker::Internet.email

    csv << [name, uid, provider, email]
  end
end
