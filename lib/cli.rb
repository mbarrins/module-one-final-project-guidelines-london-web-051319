require 'tty-prompt'

class UserInterface
    attr_accessor :user

    @@prompt = TTY::Prompt.new

    # first page   
    
    def splash_page
        clear
        puts "========================================================================"
        puts " Welcome to RevEnts - an app where you can search for and review events"
        puts "========================================================================"
        @@prompt.keypress("Press any key to continue")
        first_page
    end

    def first_page
        options = {
            "Login" => lambda{login}, 
            "Create Account" => lambda{create_account}, 
            "Exit" => lambda{puts "Goodbye"}
        }
        call_selection(options)
    end

    def login
        clear
        user_info = @@prompt.collect do
            key(:username).ask('Username:') do |q| 
                q.required true
                q.modify :downcase 
                end
            key(:password).mask('Password:')
        end
        user_match = User.find_by(user_info)
        if user_match
            @user = user_match
            home_page
        else puts "Username or password is incorrect"
            @@prompt.keypress("Press any key to continue")
            first_page
        end
    end

    def create_account
        clear
        username = @@prompt.ask('Please choose a username:', required: true).downcase
        user_match = User.find_by(username: username)
        if !user_match
            user_info = @@prompt.collect do
                key(:password).mask('Please enter a password:', required: true)
                key(:first_name).ask('Please enter your first name:', required: true)
                key(:last_name).ask('Please enter your last name:', required: true)
                key(:email).ask('Please enter your email:'){|q| q.validate(:email, 'Please enter a valid email address.')}
                key(:city).ask('(Optional) Please enter your home city:')
                key(:country).ask('(Optional) Please enter your home country:', value: "GB")
            end
            user_info[:username] = username
            @user = User.create(user_info)
            home_page
        else puts "Sorry, that username is already taken"
            @@prompt.keypress("Press any key to continue")
            create_account
        end
    end

    # home page

    def home_page
        clear
        if !!user
            puts "Welcome #{user.first_name} to your RevEnts Home Page!"
            options = {
                "Events" => lambda{events_menu}, 
                "My Reviews" => lambda{reviews_menu}, 
                "My Account" => lambda{account}, 
                "Logout" => lambda{first_page}
            }
            
            call_selection(options)
        else
            first_page
        end
    end

    # reviews

    def reviews_menu
        clear
        options = {
            "All My Reviews" => lambda{user.display_all_user_reviews; reviews_menu}, 
            "New Review" => lambda{new_review}, 
            "Edit Review" => lambda{select_review_to_edit}, 
            "Delete Review" => lambda{select_review_to_delete}, 
            "Home Page" => lambda{home_page}
        }
        
        call_selection(options)
    end

    def new_review
        if user.select_user_events_to_review[1].length == 0
            puts "You have no events to review"
            @@prompt.keypress("Press any key to continue")
        else 
            options = user.select_user_events_to_review[1]
            event_ids = user.select_user_events_to_review[0]
            selection = @@prompt.select("Please choose an event to review:", options, per_page: PER_PAGE)
            choice = options.index(selection)
            create_review(event_ids[choice])
            user.reload
        end
        reviews_menu
    end

    def create_review(event_id)
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

    def select_review_to_edit
        clear
        if user.reviews.length == 0
            puts "You have no events to edit"
            @@prompt.keypress("Press any key to continue")
        else 
            reviews = user.reviews
            options = reviews.map.with_index(1){|review, i| "#{i}: #{review.event.event_name}"} << "Cancel"
            selection = @@prompt.select("Please choose a review to edit:", options, per_page: PER_PAGE)
            if selection != "Cancel"
                choice = options.index(selection)
                edit_review(reviews[choice])
                user.reload
            end
        end

        reviews_menu
    end

    def select_review_to_delete
        clear
        if user.reviews.length == 0
            puts "You have no reviews"
            @@prompt.keypress("Press any key to continue")
        else 
            reviews = user.reviews
            options = reviews.map.with_index(1){|review, i| "#{i}: #{review.event.event_name}"} << "Cancel"
            selection = @@prompt.select("Please choose a review to delete:", options, per_page: PER_PAGE)
            if selection != "Cancel"
                choice = options.index(selection)
                reviews[choice].destroy
                puts "Review successfully deleted!"
                @@prompt.keypress("Press any key to continue")
                user.reload
            end
        end

        reviews_menu
    end

    def edit_review(review_obj)
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
        puts "Review successfully edited!"
        @@prompt.keypress("Press any key to continue")
    end

    # my account

    def account
        user_prompt = self.user
        options = {
            "Change Username" => lambda{new_username = @@prompt.ask('Please choose a new username:', value: user.username); user.change_username(new_username); account}, 
            "Change Name" => lambda{change_name_prompt; self.user.reload; account}, 
            "Change Email Address" => lambda{new_email = @@prompt.ask('Please choose a new email address', value: user_prompt.email); user.change_email(new_email); user.reload; account}, 
            "Change City" => lambda{new_city = @@prompt.ask('Please choose a new city', value: user_prompt.city || ""); user.change_city(new_city); user.reload; account}, 
            "Change Country" => lambda{new_country = @@prompt.ask('Please choose a new country', value: user_prompt.country || ""); user.change_country(new_country); user.reload; account}, 
            "Delete Account" => lambda{user.delete_account; first_page}, 
            "Home" => lambda{home_page}
        }

        clear
        call_selection(options)
    end

    # events

    def events_menu
        options = {
            "My Upcoming Events" => lambda{user.display_future_user_events; events_menu}, 
            "All My Events" => lambda{user.display_all_user_events; events_menu}, 
            "Search For Events" => lambda{search_choice}, 
            "Remove Event" => lambda{remove_event}, 
            "Home Page" => lambda{home_page}
        }

        clear
        call_selection(options)
    end

    def search_choice
        options = {
            "Search by Event Name" => lambda{event_search}, 
            "Search by Event Type" => lambda{event_type_search}, 
            "Event Home" => lambda{events_menu}
        }
        
        clear
        call_selection(options)
    end


    def remove_event
        if user.user_events.length == 0
            puts "You have no events"
            @@prompt.keypress("Press any key to continue")
        else 
            events = user.user_events
            options = events.map.with_index(1){|event, i| "#{i}: #{event.event_date.event_date_name}, #{event.event_date.start_date}, #{event.event_date.venue.city}"} << "Cancel"
            selection = @@prompt.select("Please choose an event to delete:", options, per_page: PER_PAGE)
            if selection != "Cancel"
                choice = options.index(selection)
                events[choice].destroy
                user.reload
                puts "Event successfully removed!"
                @@prompt.keypress("Press any key to continue")
            end
        end
        events_menu
    end
    
    # search functionality

    def event_type_search
        clear
        user_prompt = self.user
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
        start_date_valid = false
        end_date_valid = false

        search_info = @@prompt.collect do
            puts "Please enter the date range to search:"
            while !start_date_valid
                start_date = key(:startDateTime).ask(' Start date:') do |q|
                    q.value Date.today.strftime("%d/%m/%Y")
                end

                start_date_valid = ((Date.strptime(start_date, "%d/%m/%Y") > Date.yesterday) rescue false)
                puts "Please enter a valid future date." if !start_date_valid
            end

            while !end_date_valid
                end_date = key(:endDateTime).ask(' End date:') do |q|
                    q.value Date.today.next_month.strftime("%d/%m/%Y")
                end

                end_date_valid = (Date.strptime(end_date, "%d/%m/%Y") > Date.yesterday rescue false)
                puts "Please enter a valid future date." if !end_date_valid
            end

            key(:city).ask('Please enter the city to search:', value: user_prompt.city || "")
            key(:countryCode).ask('Please enter the country to search:', value: user_prompt.country || "")
        end
        
        search_info = search_info.select{|q,a| !!a}
        
        search_info[:startDateTime] = (Date.strptime(search_info[:startDateTime], "%d/%m/%Y").strftime("%F")) << "T00:00:00Z"
        search_info[:endDateTime] = (Date.strptime(search_info[:endDateTime], "%d/%m/%Y").strftime("%F")) << "T23:59:00Z"

        search_string = search_info.map {|key,search| "&#{key}=#{search}"} << "&subGenreId=#{sub_genres[choice].tm_sub_genre_id}"
        search_string = search_string.join("")

        events_data = EventApiData.new_with_data(url: EVENTSURL, api_key: APIKEY, search_string: search_string)

        select_event_to_create(events_data)
        
    end



    def event_search
        clear
        user_prompt = self.user
        puts "Please enter search criteria. Leave blank to exclude from search."
        start_date_valid = false
        end_date_valid = false

        search_info = @@prompt.collect do |q|
            key(:keyword).ask('Please enter the name of the event:')
            puts "Please enter the date range to search:"

            while !start_date_valid
                start_date = key(:startDateTime).ask(' Start date:') do |q|
                    q.value Date.today.strftime("%d/%m/%Y")
                end

                start_date_valid = (Date.strptime(start_date, "%d/%m/%Y") rescue false) && ((Date.strptime(start_date, "%d/%m/%Y") > Date.yesterday) rescue false)
                puts "Please enter a valid future date." if !start_date_valid
            end
            
            while !end_date_valid
                end_date = key(:endDateTime).ask(' End date:') do |q|
                    q.value Date.today.next_month.strftime("%d/%m/%Y")
                end

                end_date_valid = (Date.strptime(end_date, "%d/%m/%Y") rescue false) && (Date.strptime(end_date, "%d/%m/%Y") > Date.yesterday rescue false)
                puts "Please enter a valid future date." if !end_date_valid
            end

            key(:city).ask('Please enter the city to search:', value: user_prompt.city || "")
            key(:countryCode).ask('Please enter the country to search:', value: user_prompt.country || "")
        end
        
        search_info = search_info.select{|q,a| !!a}
        
        search_info[:startDateTime] = (Date.strptime(search_info[:startDateTime], "%d/%m/%Y").strftime("%F")) << "T00:00:00Z"
        search_info[:endDateTime] = (Date.strptime(search_info[:endDateTime], "%d/%m/%Y").strftime("%F")) << "T23:59:00Z"
        
        search_string = search_info.map {|key,search| "&#{key}=#{search}"}.join("")
        events_data = EventApiData.new_with_data(url: EVENTSURL, api_key: APIKEY, search_string: search_string)

        select_event_to_create(events_data)

    end

    def select_event_to_create(events_data)
        clear
        events_details = events_data.search_results
        if events_details.length == 0
            puts "Your search returned no events"
            @@prompt.keypress("Press any key to continue")
            events_menu
        else    
            options = make_event_options(events_data)
            selection = @@prompt.select("Please choose an event:", options, per_page: PER_PAGE)
            choice = options.index(selection)
            if choice < events_details.length
                tm_event_id = events_details[choice][:event][:tm_event_id]
                chosen_event = Event.find_by(tm_event_id: tm_event_id)
                selected_events_menu(chosen_event, events_data, choice)
            elsif choice == options.index("Next #{events_data.page_size} Events")
                events_data.page_no += 1
                select_event_to_create(events_data)
            elsif choice == options.index("Prev #{events_data.page_size} Events")
                events_data.page_no -= 1
                select_event_to_create(events_data)
            else
                events_menu
            end
        end
    
    end

    def selected_events_menu(chosen_event, events_data, choice)
        options = {
            "View Reviews" => lambda{view_reviews(chosen_event); selected_events_menu(chosen_event, events_data, choice)}, 
            "Add to my events" => lambda{user.add_event_from_json(events_data.search_results[choice]); select_event_to_create(events_data)}, 
            "Back to Search" => lambda{events_menu}
        }
        
        clear
        call_selection(options)
    end

    def view_reviews(event)
        if !!event
            event.display_reviews
            @@prompt.keypress("Press space or enter to return event", keys: [:space, :return])
        else
            puts "There are no reviews for this event"
            @@prompt.keypress("Press any key to continue")
        end

    end

    def make_event_options(events_data)
        options = events_data.search_results.map.with_index(1) do |event, i| 
            "Event #{i+(events_data.page_no*events_data.search_results.length)}: #{event[:event][:event_name]}\n" << 
            "Event name: #{event[:event_date][:event_date_name]}\n" <<
            "When: #{event[:event_date][:start_date]} at #{event[:event_date][:start_time]}\n" <<
            "Where: #{event[:venue][:venue_name]}, #{event[:venue][:city]}, #{event[:venue][:postcode]}\n" <<
            "--------------------------"
        end

        if !!events_data.next_url
            options << "Next #{events_data.page_size} Events"
        end

        if events_data.page_no != 0
            options << "Prev #{events_data.page_size} Events"
        end

        options << "Back to Events Menu"

        options
    end

   

    private

    def selection(options)
        selection = @@prompt.select("Please choose an option:", options, per_page: PER_PAGE)
        options.index(selection)
    end

    def call_selection(options)
        selection = @@prompt.select("What would you like to do?", options.keys, per_page: PER_PAGE)
        options[selection].call
    end

    def change_name_prompt
        user_prompt = self.user
        name = @@prompt.collect do
            key(:first_name).ask('Please enter your new first name:', value: user_prompt.first_name, required: true)
            key(:last_name).ask('Please enter your new last name:', value: user_prompt.last_name, required: true)
        end
        user.change_name(name)
    end

    def clear
        puts
        print "\e[2J\e[f"
    end

    end