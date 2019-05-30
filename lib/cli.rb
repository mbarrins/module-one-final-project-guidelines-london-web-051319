require 'tty-prompt'

class UserInterface
    attr_accessor :user

    @@prompt = TTY::Prompt.new

    # first page    

    def first_page
        options = {
            "Login" => lambda{login}, 
            "Create Account" => lambda{create_account}, 
            "Exit" => lambda{puts "Goodbye"}
        }
        
        call_selection(options)
    end

    def login
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
            first_page
        end
    end

    def create_account
        username = @@prompt.ask('Please choose a username:', required: true).downcase
        user_match = User.find_by(username: username)
        if !user_match
            user_info = @@prompt.collect do
                key(:password).mask('Please enter a password:', required: true)
                key(:first_name).ask('Please enter your first name:')
                key(:last_name).ask('Please enter your last name:')
                key(:email).ask('Please enter your email:'){|q| q.validate(:email, 'Please enter a valid email address.')}
                key(:city).ask('(Optional) Please enter your home city:')
                key(:country).ask('(Optional) Please enter your home country:')
            end
            user_info[:username] = username
            @user = User.create(user_info)
            home_page
        else puts "Sorry, that username is already taken"
            create_account
        end
    end

    # home page

    def home_page
        if !!user
            puts "Welcome #{user.first_name}! \n"
            options = {
                "Events" => lambda{events_menu}, 
                "My Reviews" => lambda{reviews}, 
                "My Account" => lambda{account}, 
                "Logout" => lambda{first_page}
            }
            
            call_selection(options)
        else
            first_page
        end
    end

    # reviews

    def reviews
        options = {
            "All My Reviews" => lambda{user.display_all_user_reviews; reviews}, 
            "New Review" => lambda{new_review}, 
            "Edit Review" => lambda{select_review_to_edit}, 
            "Delete Review" => lambda{select_review_to_delete}, 
            "Home Page" => lambda{home_page}
        }
        
        call_selection(options)
    end

    def new_review
        if user.select_user_events_to_review[1].length == 0
            puts "You have reviewed all your events"
        else options = user.select_user_events_to_review[1]
        event_ids = user.select_user_events_to_review[0]
        selection = @@prompt.select("Please choose an event to review:", options)
        choice = options.index(selection)
        create_review(event_ids[choice])
        user.reload
        reviews
        end
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
        if user.reviews.length == 0
            puts "You have reviewed all your events"
        else reviews = user.reviews
        options = reviews.map.with_index(1){|review, i| "#{i}: #{review.event.event_name}"} << "Cancel"
        selection = @@prompt.select("Please choose a review to edit:", options)
        if selection != "Cancel"
            choice = options.index(selection)
            edit_review(reviews[choice])
            user.reload
        end
        reviews
        end
    
    end

    def select_review_to_delete
        if user.reviews.length == 0
            puts "You have no reviews"
        else reviews = user.reviews
        options = reviews.map.with_index(1){|review, i| "#{i}: #{review.event.event_name}"} << "Cancel"
        selection = @@prompt.select("Please choose a review to delete:", options)
        if selection != "Cancel"
            choice = options.index(selection)
            reviews[choice].destroy
            user.reload
        end
        reviews
        end
    
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
    end

    # my account

    def account
        change_name = lambda do
            name = @@prompt.collect do
                key(:first_name).ask('Please enter your new first name:')
                key(:last_name).ask('Please enter your new last name:')
            user.change_name(name)
            end
        end

        options = {
            "Change Username" => lambda{new_username = @@prompt.ask('Please choose a new username:'); user.change_username(new_username); account}, 
            "Change Name" => lambda{change_name; account}, 
            "Change Email Address" => lambda{new_email = @@prompt.ask('Please choose a new email address'); user.change_email(new_email); account}, 
            "Change City" => lambda{new_city = @@prompt.ask('Please choose a new city'); user.change_city(new_city); account}, 
            "Change Country" => lambda{new_country = @@prompt.ask('Please choose a new country'); user.change_country(new_country); account}, 
            "Delete Account" => lambda{user.delete_account; first_page}, 
            "Home" => lambda{home_page}
        }
        
        call_selection(options)
    end

    # events

    def events_menu
        options = {
            "My Upcoming Events" => lambda{user.display_future_user_events; events_menu}, 
            "All My Events" => lambda{user.display_all_user_events; events_menu}, 
            "Add New Event" => lambda{search_choice}, 
            "Remove Event" => lambda{remove_event}, 
            "Home Page" => lambda{home_page}
        }
        
        call_selection(options)
    end

    def search_choice
        options = {
            "Search by Event Name" => lambda{event_search}, 
            "Search by Event Type" => lambda{event_type_search}, 
            "Event Home" => lambda{events_menu}
        }
    
        call_selection(options)
    end


    def remove_event
        if user.user_events.length == 0
            puts "You have no events"
        else 
            events = user.user_events
            options = events.map.with_index(1){|event, i| "#{i}: #{event.event_date.event_date_name}, #{event.event_date.start_date}, #{event.event_date.venue.city}"} << "Cancel"
            selection = @@prompt.select("Please choose an event to delete:", options)
            if selection != "Cancel"
                choice = options.index(selection)
                events[choice].destroy
                user.reload
                puts "Event successfully removed!"
            end
        end
        events_menu
    end
    
    # search functionality

    def event_type_search
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

        events_data = EventApiData.new_with_data(url: EVENTSURL, api_key: APIKEY, search_string: search_string)

        select_event_to_create(events_data)
        
    end



    def event_search
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
        events_data = EventApiData.new_with_data(url: EVENTSURL, api_key: APIKEY, search_string: search_string)

        select_event_to_create(events_data)

    end

    def select_event_to_create(events_data)
        events_details = events_data.search_results
        if events_details.length == 0
            puts "Your search returned no events"
            events_menu
        else 
            options = make_event_options(events_data)
            selection = @@prompt.select("Please choose an event to add:", options)
            choice = options.index(selection)
            if choice < events_details.length
                tm_event_id = events_details[choice][2][:tm_event_id]
                event_id = Event.find_by(tm_event_id: tm_event_id)
                selected_events_menu(event_id, events_details, choice)
            elsif choice == options.index("Load More")
                events_details.page_no += 1
                select_event_to_create(events_data)
            else
                events_menu
            end
        end
    
    end

    def selected_events_menu(event_id, events, choice)
        options = {"View Reviews" => lambda{view_reviews(event_id)}, 
            "Add to my events" => lambda{user.add_event_from_json(events[choice]); events_menu}, 
            "Back to Search" => lambda{events}}
        call_selection(options)
    end

    def view_reviews(event_id)
        Review.find_by(event_id: event_id)

    
    end

    def make_event_options(events_data)
        options = (events_data.search_results.map.with_index(1) do |event, i| 
            "Event #{i+(events_data.page_no*events_data.search_results.length)}: #{event[2][:event_name]}\n" << 
            "Event name: #{event[0][:event_date_name]}\n" <<
            "When: #{event[0][:start_date]} at #{event[0][:start_time]}\n" <<
            "Where: #{event[1][:venue_name]}, #{event[1][:city]}, #{event[1][:postcode]}\n" <<
            "--------------------------"
        end << (!events_data.next_url ? "Back" : ["Load More", "Back"])).flatten
        options
    end

   

    private

    def selection(options)
        selection = @@prompt.select("Please choose an option:", options)
        options.index(selection)
    end

    def call_selection(options)
        selection = @@prompt.select("Please choose an option:", options.keys)
        options[selection].call
    end
end