module Sinatra
  module Helpers
    def login_required
      return true if current_user.class != GuestUser

      if request.xhr?
        redirect 403
      else
        session[:return_to] = request.fullpath 
        redirect '/login'
      end

      false
    end
  end
end

module Sinatra
  module SinatraAuthentication
    class << self
      alias_method :orig_registered, :registered

      def registered(app)
        orig_registered(app)
        
        app.get '/newuser' do
          haml get_view_as_string("newuser.haml"), :layout => use_layout?
        end

        app.post '/newuser' do
          if params[:email] != params[:email_confirmation]
            flash[:errors] = "Email and confirmation email do not match"
            redirect '/newuser?' + hash_to_query_string(params)
          else
            password = PasswordGenerator.generate
            p password
            @user = User.set(email: params[:email], password: password, password_confirmation: password)
            if @user.valid && @user.id
              flash[:notice] = "Account created."
              redirect '/users'
            else
              flash[:errors] = "#{@user.errors}"
              redirect '/newuser?' + hash_to_query_string(params)
            end
          end
        end
      end
      
    end
  end
end