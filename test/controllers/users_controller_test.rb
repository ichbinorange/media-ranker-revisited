require "test_helper"

describe UsersController do

  describe "index" do
    it "can get the index path for logged-in user" do
      # Arrange
      user = perform_login(users(:dan))

      # Act
      get users_path

      # Assert
      must_respond_with :success
    end

    it "cannot get the index path for guest" do
      # Act
      get users_path

      # Assert
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "can get a valid user for logged-in user" do
      # Arrange
      logged_in_user = perform_login(users(:dan))
      user = users(:dan)

      # Act
      get user_path(user)

      # Assert
      must_respond_with :success
    end

    it "will respond with 404 for invalid user" do
      # Arrange
      invalid_user = -1

      # Act
      get user_path(invalid_user)
    
      # Assert
      must_respond_with :not_found
    end

    it "cannot get a valid user for guest" do
      # Arrange
      user = users(:dan)

      # Act
      get user_path(user)

      # Assert
      must_redirect_to root_path
    end
  end

  describe "create" do
    it "can log in an existing user" do
      # Act  
      user = perform_login(users(:dan))

      # Assert
      expect(session[:user_id]).must_equal user.id
      must_respond_with :redirect
    end

    it "can log in a new user with valid user data" do
      # Arrange
      new_user = User.new(uid: "1111", username: "Test", provider: "github", email: "email@gmail.com")

      # Act
      expect{
        perform_login(new_user)
      }.must_change "User.count", 1

      # Arrange
      user = User.last
      expect(session[:user_id]).must_equal user.id
      expect(user.uid).must_equal new_user.uid
      must_respond_with :redirect
    end

    it "redirects to root path if given invalid user data" do
      # Arrange
      start_count = User.count
    
      user = User.new(provider: 'github', uid: 34567, email: 'don@trump_tower.com', username: nil)

      # Act
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
    
      get omniauth_callback_path(:github)
 
      # Arrange
      must_redirect_to root_path
      expect(user.id).must_be_nil
      expect(session[:user_id]).must_be_nil
      expect(User.count).must_equal start_count
    end
  end

  describe "destroy" do
    it "can logout an existing user" do
      # Arrange
      user = perform_login(users(:dan))
      expect(session[:user_id]).must_equal user.id
      
      # Act
      expect {
        delete logout_path
      }.wont_change "User.count"

      # Assert
      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end

  # Tests written for Oauth.    
  # describe "auth_callback" do
  #   it "logs in an existing user and redirects to the root path" do
  #     user = users(:dan)

  #     expect {
  #       perform_login(user)
  #     }.wont_change "User.count"

  #     must_redirect_to root_path
  #     expect(session[:user_id]).must_equal user.id
  #     expect(flash[:notice]).must_equal "Logged in as returning user #{user.username}"
  #   end

  #   it "creates an account for a new user and redirects to the root route" do
  #     user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")

  #     expect {
  #       perform_login(user)
  #     }.must_differ "User.count", 1

  #     must_redirect_to root_path
  #     expect(session[:user_id]).must_equal(User.find_by(provider: user.provider, 
  #       uid: user.uid, email: user.email).id)
  #       expect(flash[:notice]).must_equal "Logged in as new user #{user.username}"

  #   end

  #   it "will handle a request with invalid information" do
  #     user = User.new(provider: "github", uid: nil, username: nil, email: nil)
  #     expect {
  #       perform_login(user)
  #     }.wont_change "User.count"

  #     # you can either respond with a bad request or redirect and give a flash notice
  #     # Option 1
  #     # must_respond_with :bad_request

  #     # Option 2
  #     must_redirect_to root_path
  #     expect(flash[:error]).must_equal ["Could not create new user account username: [\"can't be blank\"]"]
  #     expect(session[:user_id]).must_equal nil
  #   end
  # end

  # describe "logout" do
  #   it "will log out a logged in user" do
  #     user = users(:dan)
  #     perform_login(user)

  #     post logout_path

  #     must_redirect_to root_path
  #     expect(session[:user_id]).must_equal nil
  #     expect(flash[:notice]).must_equal "Successfully logged out"
  #   end

  #   it "will redirect back and give a flash notice if a guest user tries to logout" do
  #     post logout_path

  #     must_redirect_to root_path
  #     expect(session[:user_id]).must_equal nil
  #     expect(flash[:warning]).must_equal "You were not logged in!"
  #   end
  # end

end
