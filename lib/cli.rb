require 'tty-prompt'

class UserInterface

    @@prompt = TTY::Prompt.new

    def self.first_page
        #options = ["Login", "Create Account", "Exit"]
        options = {
            "Login" => lambda{login}, 
            "Create Account" => lambda{create_account}, 
            "Exit" => lambda{puts "Goodbye"}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     login
        # elsif choice == 1
        #     create_account
        # elsif choice == 2
        #     puts "Goodbye"
        # end
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
                key(:email).ask('Please enter your email:'){|q| q.validate(:email, 'Please enter a valid email address.')}
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
        puts "Welcome #{user.first_name}! \n"
        #options = ["Events", "My Reviews", "My Account", "Logout"]
        options = {
            "Events" => lambda{events(user)}, 
            "My Reviews" => lambda{reviews(user)}, 
            "My Account" => lambda{account(user)}, 
            "Logout" => lambda{first_page}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     events(user)
        # elsif choice == 1
        #     reviews(user)
        # elsif choice == 2
        #     account(user)
        # else
        #     first_page
        # end

    end

    def self.events(user)
        #options = ["My Upcoming Events", "All My Events", "Add New Event", "Remove Event", "Home Page"]
        options = {
            "My Upcoming Events" => lambda{user.display_future_user_events; events(user)}, 
            "All My Events" => lambda{user.display_all_user_events; events(user)}, 
            "Add New Event" => lambda{search_choice(user)}, 
            "Remove Event" => lambda{remove_event(user)}, 
            "Home Page" => lambda{home_page(user)}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     user.display_future_user_events
        #     events(user)
        # elsif choice == 1
        #     user.display_all_user_events
        #     events(user)
        # elsif choice == 2
        #     search_choice(user)
        # elsif choice == 3
        #     remove_event(user)
        # else
        #     home_page(user)
        # end
    end

    def self.reviews(user)
        #options = ["All My Reviews", "New Review", "Edit Review", "Home Page"]
        options = {
            "All My Reviews" => lambda{user.display_all_user_reviews; reviews(user)}, 
            "New Review" => lambda{new_review(user)}, 
            "Edit Review" => lambda{select_review_to_edit(user); reviews(user)}, 
            "Home Page" => lambda{home_page(user)}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     user.display_all_user_reviews
        #     reviews(user)
        # elsif choice == 1
        #     new_review(user)
        # elsif choice == 2
        #     select_review_to_edit(user)
        #     reviews(user)
        # else
        #     home_page(user)
        # end
    end

    def self.new_review(user)
        if user.select_user_events_to_review[1].length == 0
            puts "You have reviewed all your events"
        else options = user.select_user_events_to_review[1]
        event_ids = user.select_user_events_to_review[0]
        selection = @@prompt.select("Please choose an event to review:", options)
        choice = options.index(selection)
        create_review(user, event_ids[choice])
        user = User.find(user.id)
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

    def self.call_selection(options)
        selection = @@prompt.select("Please choose an option:", options.keys)
        options[selection].call

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
        #options = ["Change Username", "Change Name", "Change Email Address", "Change City", "Change Country", "Delete Account", "Home"]
        change_name = lambda do
            name = @@prompt.collect do
                key(:first_name).ask('Please enter your new first name:')
                key(:last_name).ask('Please enter your new last name:')
            user.change_name(name)
            end
        end

        options = {
            "Change Username" => lambda{new_username = @@prompt.ask('Please choose a new username:'); user.change_username(new_username)}, 
            "Change Name" => change_name, 
            "Change Email Address" => lambda{new_email = @@prompt.ask('Please choose a new email address'); user.change_email(new_email)}, 
            "Change City" => lambda{new_city = @@prompt.ask('Please choose a new city'); user.change_city(new_city)}, 
            "Change Country" => lambda{new_country = @@prompt.ask('Please choose a new country'); user.change_country(new_country)}, 
            "Delete Account" => lambda{user.delete_account}, 
            "Home" => lambda{home_page(user)}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     new_username = @@prompt.ask('Please choose a new username:')
        #     user.change_username(new_username)
        # elsif choice == 1
        #     name = @@prompt.collect do
        #         key(:first_name).ask('Please enter your new first name:')
        #         key(:last_name).ask('Please enter your new last name:')
        #     user.change_name(name)
        #     end
        # elsif choice == 2
        #     new_email = @@prompt.ask('Please choose a new email address')
        #     user.change_email(new_email)
        # elsif choice == 3
        #     new_city = @@prompt.ask('Please choose a new city')
        #     user.change_city(new_city)
        # elsif choice == 4
        #     new_country = @@prompt.ask('Please choose a new country')
        #     user.change_country(new_country)
        # elsif choice == 5
        #     user.delete_account
        # else
        #     self.home_page(user)
        # end
        account(user)
    end

    def self.search_choice(user)
        #options = ["Search by Event Name", "Search by Event Type", "Event Home"]
        options = {
            "Search by Event Name" => lambda{event_search(user)}, 
            "Search by Event Type" => lambda{event_type_search(user)}, 
            "Event Home" => lambda{events(user)}
        }
        #choice = selection(options)
        call_selection(options)
        
        # if choice == 0
        #     event_search(user)
        # elsif choice == 1
        #     event_type_search(user)
        # else
        #     events(user)
        # end
    end

    def self.event_type_search(user)
        segments = Segment.all
        options = segments.map {|segment| segment.segment_name}
        choice = selection(options)
        genres = segments[choice].genres
        options = genres.map {|genre| genre.genre_name}
        choice = selection(options)
        sub_genres = genres[choice].sub_genres
        options = sub_genres.map {|sg| sg.sub_genre_name}
        choice = selection(options)
        puts "Please enter search criteria. Leave blank to exclude from search."
        search_info = @@prompt.collect do
            key(:startDateTime).ask("Please enter the date range to search: \n Start date:", value: Date.today.strftime("%F"))<<"T00:00:00Z"
            key(:endDateTime).ask('End date:', value: Date.today.next_month.strftime("%F"))<<"T23:59:00Z"
            key(:city).ask('Please enter the city to search:')
            key(:countryCode).ask('Please enter the country to search:', value: "GB")
        end
        search_info = search_info.select{|key,value| !!value}
        search_string = search_info.map {|key,search| "&#{key}=#{search}"} << "&subGenreId=#{sub_genres[choice].tm_sub_genre_id}"
        search_string = search_string.join("")

        select_event_to_create(*Event.new_event_search(*Event.get_json_from_search_string(search_string, 0)), user)


    end



    def self.event_search(user)
        puts "Please enter search criteria. Leave blank to exclude from search."
        search_info = @@prompt.collect do
            key(:keyword).ask('Please enter the name of the event:')
            key(:startDateTime).ask("Please enter the date range to search: \n Start date:", value: Date.today.strftime("%F"))<<"T00:00:00Z"
            key(:endDateTime).ask(' End date:', value: Date.today.next_month.strftime("%F"))<<"T23:59:00Z"
            key(:city).ask('Please enter the city to search:')
            key(:countryCode).ask('Please enter the country to search:', value: "GB")
        end
        
        search_info = search_info.select{|key,value| !!value}
        search_string = search_info.map {|key,search| "&#{key}=#{search}"}.join("")

        select_event_to_create(*Event.new_event_search(*Event.get_json_from_search_string(search_string, 0)), user)

    end

    def self.select_event_to_create(events, search_string, page_no, next_url, user)
        if events.length == 0
            puts "Your search returned no events"
            events(user)
        else 
            options = make_event_options(events, page_no, next_url)
            selection = @@prompt.select("Please choose an event to add:", options)
            choice = options.index(selection)      
            if choice < events.length
                user.add_event_from_json(events[choice])
                user = User.find(user.id)
                events(user)
            elsif choice == options.index("Load More")
                page_no += 1
                # binding.pry
                select_event_to_create(*Event.new_event_search(*Event.get_json_from_search_string(search_string, page_no)), user)
            else
                events(user)
            end
        end
    
    end

    def self.make_event_options(events, page_no, next_url)
        options = (events.map.with_index(1) do |event, i| 
            "Event #{i+(page_no*events.length)}: #{event[2][:event_name]}\n" << 
            "Event name: #{event[0][:event_date_name]}\n" <<
            "When: #{event[0][:start_date]} at #{event[0][:start_time]}\n" <<
            "Where: #{event[1][:venue_name]}, #{event[1][:city]}, #{event[1][:postcode]}\n" <<
            "--------------------------"
        end << (!next_url ? "Back" : ["Load More", "Back"])).flatten
        options
    end

    def self.remove_event(user)
        if user.user_events.length == 0
            puts "You have no events"
        else events = user.user_events
        options = events.map.with_index(1){|event, i| "#{i}: #{event.event_date.event_date_name}, #{event.event_date.start_date}, #{event.event_date.venue.city}"}
        selection = @@prompt.select("Please choose an event to delete:", options)
        choice = options.index(selection)
        events[choice].destroy
        user = User.find(user.id)
        puts "Event successfully removed!"
        end
        events(user)
    end

end