require 'tty-prompt'

class UserInterface

    @@prompt = TTY::Prompt.new

    def self.first_page
        options = ["Login", "Create Account"]
        selection = @@prompt.select("Please choose an option:", options)
        choice = options.index(selection)
        if choice == 0
            login
        elsif choice == 1
            create_account
        end
    end

    def self.login
        user_info = @@prompt.collect do
            key(:username).ask('Username:')
            key(:password).mask('Password:')
        end
        user = User.find_by(user_info)
        if user
        user
        else puts "Username or password is incorrect"
            first_page
        end
    end

end