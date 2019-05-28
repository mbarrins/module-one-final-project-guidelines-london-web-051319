require 'tty-prompt'

class UserInterface

    @@prompt = TTY::Prompt.new

    def self.first_page
        options = ["Login", "Create Account", "Exit"]
        selection = @@prompt.select("Please choose an option:", options)
        choice = options.index(selection)
        if choice == 0
            login
        elsif choice == 1
            create_account
        elsif choice == 2
            puts "Goodbye"
        end
    end

    def self.login
        user_info = @@prompt.collect do
            key(:username).ask('Username:') do |q| 
                q.required true
                q.modify :downcase 
                end
            key(:password).mask('Password:')
        end
        user = User.find_by(user_info)
        if user
            home_page(user)
        else puts "Username or password is incorrect"
            first_page
        end
    end

    def self.create_account
        username = @@prompt.ask('Please choose a username:', required: true).downcase
        user = User.find_by(username: username)
        if !user
            user_info = @@prompt.collect do
                key(:password).mask('Please enter a password:', required: true)
                key(:first_name).ask('Please enter your first name:')
                key(:last_name).ask('Please enter your last name:')
                key(:email).ask('Please enter your email:')
                key(:city).ask('(Optional) Please enter your home city:')
                key(:country).ask('(Optional) Please enter your home country:')
            end
            user_info[:username] = username
            new_user = User.create(user_info)
            home_page(new_user)
        else puts "Sorry, that username is already taken"
            create_account
        end
    end

    def self.home_page(user)
        options = ["Events", "My Reviews", "My Account", "Logout"]
        selection = @@prompt.select("Please choose an option:", options)
        choice = options.index(selection)
        if choice == 0
            events(user)
        elsif choice == 1
            reviews(user)
        elsif choice == 2
            account(user)
        else
            first_page
        end
    end

    def self.events(user)
        options = ["My Upcoming Events", "All My Events", "Event Search", "Home Page"]
        selection = @@prompt.select("Please choose an option:", options)
        choice = options.index(selection)
        if choice == 0
            user.future_user_events
        elsif choice == 1
            user.events
        elsif choice == 2
            event_search(user)
        else
            first_page
        end
    end

end