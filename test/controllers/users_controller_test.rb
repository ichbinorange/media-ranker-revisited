require "test_helper"

describe UsersController do
  describe "index" do
    it "can get the index path" do
      # Act
      get users_path

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "can get a valid user" do
      # Arrange
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
  end

  describe "create" do
    it "can log in an existing user" do
      # Act  
      user = perform_login(users(:dan))

      # Assert
      expect(session[:user_id]).must_equal user.id
      must_respond_with :redirect
    end

    it "can log in a new user" do
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

    it "redirects to the login route if given invalid user data" do
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
end
