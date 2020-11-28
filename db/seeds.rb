require "csv"

USER_FILE = Rails.root.join('db', 'users_seeds.csv')
puts "Loading raw product data from #{USER_FILE}"

user_failures = []
CSV.foreach(USER_FILE, :headers => true) do |row|
  user = User.new
  user.username = row['username']
  user.uid = row['uid']
  user.provider = row['provider']
  user.email = row['email']
  successful = user.save
  if !successful
    user_failures << user
    puts "Failed to save user: #{user.inspect}"
  else
    puts "Created user: #{user.inspect}"
  end
end


media_file = Rails.root.join("db", "media_seeds.csv")

CSV.foreach(media_file, headers: true, header_converters: :symbol, converters: :all) do |row|
  data = Hash[row.headers.zip(row.fields)]
  puts data
  Work.create!(data)
end