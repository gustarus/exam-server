namespace :service do
  desc 'Register new user in control panel.'
  task :register, [:email, :password, :admin] => :environment do |t, args|
    email = args[:email].strip
    password = args[:password].strip
    admin = args[:admin].strip === 'true' ? true : false

    user = User.create!(:email => email, :password => password, :admin => admin)
    if user
      puts "User #{email} was created successfully."
    else
      puts "Unable to create user #{email}."
    end
  end
end
