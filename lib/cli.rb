require 'tty-prompt'

class UserInterface

    @@prompt = TTY::Prompt.new

    def self.first_page
        options = ["Login", "Create Account", "Exit"]
        choice = selection(options)
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
        choice = selection(options)
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
        choice = selection(options)
        if choice == 0
            user.display_future_user_events
            events(user)
        elsif choice == 1
            user.display_all_user_events
            events(user)
        elsif choice == 2
            event_search(user)
        else
            home_page(user)
        end
    end

    def self.reviews(user)
        options = ["All My Reviews", "New Review", "Edit Review", "Home Page"]
        choice = selection(options)
        if choice == 0
            user.display_all_user_reviews
            reviews(user)
        elsif choice == 1
            if user.select_user_events_to_review[1].length == 0
                puts "You have reviewed all your events"
            else options = user.select_user_events_to_review[1]
            event_ids = user.select_user_events_to_review[0]
            selection = @@prompt.select("Please choose an event to review:", options)
            choice = options.index(selection)
            create_review(user, event_ids[choice])
            user = User.find(user.id)
            end
            reviews(user)
        elsif choice == 2
            select_review_to_edit(user)
            reviews(user)
        else
            home_page(user)
        end
    end

    def self.create_review(user, event_id)
        review_info = @@prompt.collect do
            key(:rating).ask('Please enter your rating for this event (1-10):') do |q| 
                    q.required true
                    q.validate /^(?:[1-9]|0[1-9]|10)$/
                    q.messages[:valid?] = "Please enter rating between 1-10. They're not that good!"
                    end
            key(:review).ask('Please enter your review:')
        end
        review_info[:user_id] = user.id
        review_info[:event_id] = event_id
        Review.create(review_info)
    end

    def self.selection(options)
        selection = @@prompt.select("Please choose an option:", options)
        options.index(selection)
    end

    def self.select_review_to_edit(user)
        if user.reviews.length == 0
            puts "You have reviewed all your events"
        else reviews = user.reviews
        options = reviews.map.with_index(1){|review, i| "#{i}: #{review.event.event_name}"}
        selection = @@prompt.select("Please choose a review to edit:", options)
        choice = options.index(selection)
        edit_review(reviews[choice])
        user = User.find(user.id)
        end
    
    end

    def self.edit_review(review_obj)
        review_info = @@prompt.collect do
            key(:rating).ask('Please enter your new rating for this event (1-10):') do |q| 
                q.required true
                q.validate /^(?:[1-9]|0[1-9]|10)$/
                q.messages[:valid?] = "Please enter rating between 1-10. They're not that good!"
                q.value review_obj.rating.to_s
                end
            key(:review).ask('Please enter your new review:', value: review_obj.review)
        end
        review_obj.update(review_info)
    end

    def self.account(user)
        options = ["Change Username", "Change Name", "Change Email Address", "Change City", "Change Country", "Delete Account", "Home"]
        choice = selection(options)
        if choice == 0
            new_username = @@prompt.ask('Please choose a new username:')
            user.change_username(new_username)
        elsif choice == 1
            # name = @@prompt.collect do
            #     key(:first_name).ask('Please enter your new first name:')
            #     key(:last_name).ask('Please enter your new last name:')
            # user.change_name(name)
            # end
        elsif choice == 2
            new_email = @@prompt.ask('Please choose a new email address')
            user.change_email(new_email)
        elsif choice == 3
            new_city = @@prompt.ask('Please choose a new city')
            user.change_city(new_city)
        elsif choice == 4
            new_country = @@prompt.ask('Please choose a new country')
            user.change_country(new_country)
        elsif choice == 5
            user.delete_account
        else
            self.home_page(user)
        end
        self.account(user)
    end

end