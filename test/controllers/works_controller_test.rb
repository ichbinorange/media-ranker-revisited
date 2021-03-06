require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }

  describe "root" do
    it "succeeds with all media types" do
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      only_book = works(:poodr)
      only_book.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all do |work|
        work.destroy
      end

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works for logged-in user" do
      # Arrange
      logged_in_user = perform_login(users(:dan))

      # Act
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works for logged-in user" do
      # Arrange
      logged_in_user = perform_login(users(:dan))

      Work.all do |work|
        work.destroy
      end

      get works_path

      must_respond_with :success
    end

    it "redirects to root_path for guest" do
      # Act
      get works_path

      # Assert
      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category for logged-in user" do
      # Arrange
      logged_in_user = perform_login(users(:dan))

      new_work = { work: { title: "Dirty Computer", category: "album" } }

      expect {
        post works_path, params: new_work
      }.must_change "Work.count", 1

      new_work = Work.find_by(title: "Dirty Computer")

      expect(new_work.user_id).must_equal logged_in_user.id
      must_respond_with :redirect
      must_redirect_to work_path(new_work.id)
    end

    it "renders bad_request and does not update the DB for guest" do  
      
      new_work = { work: { title: "Dirty Computer", category: "album" } }

      expect {
        post works_path, params: new_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders bad_request and does not update the DB for bogus data" do
      logged_in_user = perform_login(users(:dan))

      bad_work = { work: { title: nil, category: "book" } }

      expect {
        post works_path, params: bad_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        invalid_work = { work: { title: "Invalid Work", category: category } }

        expect { post works_path, params: invalid_work }.wont_change "Work.count"

        expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    it "succeeds for an extant work ID for logged-in user" do
      # Arrange
      logged_in_user = perform_login(users(:dan))

      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      destroyed_id = existing_work.id
      existing_work.destroy

      get work_path(destroyed_id)

      must_respond_with :not_found
    end

    it "redirects to root_path for an extant work ID for guest" do
      get work_path(existing_work.id)

      must_redirect_to root_path
    end
  end

  describe "edit" do
    it "succeeds for an associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:dan))

      get edit_work_path(existing_work.id)

      edit_work = Work.find_by(id: existing_work.id)

      expect(edit_work.user_id).must_equal logged_in_user.id

      must_respond_with :success
    end

    it "redirects for a non-associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:kari))

      get edit_work_path(existing_work.id)

      edit_work = Work.find_by(id: existing_work.id)

      expect(edit_work.user_id).wont_equal logged_in_user.id

      must_respond_with :redirect
    end

    it "redirects to root_pay for guest" do
      get edit_work_path(existing_work.id)

      must_redirect_to root_path
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      get edit_work_path(bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:updates) {
        { work: { 
          title: "Dirty Computer" 
        } 
      }
    }  

    it "succeeds for valid data and an associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:dan))

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      updated_work = Work.find_by(id: existing_work.id)

      expect(updated_work.user_id).must_equal logged_in_user.id
      expect(updated_work.title).must_equal "Dirty Computer"
      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "redirects for valid data and a non-associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:kari))

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      non_updated_work = Work.find_by(id: existing_work.id)

      expect(non_updated_work.user_id).wont_equal logged_in_user.id
      expect(non_updated_work.title).wont_equal "Dirty Computer"
      must_respond_with :redirect
    end

    it "redirects to root_pay for guest" do
      put work_path(existing_work), params: updates

      must_redirect_to root_path
    end

    it "renders bad_request for bogus data from the associated work for logged-in user" do
      logged_in_user = perform_login(users(:dan))

      updates = { work: { title: nil } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      work = Work.find_by(id: existing_work.id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      put work_path(bogus_id), params: { work: { title: "Test Title" } }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:dan))

      expect {
        delete work_path(existing_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects for a non-associated work ID for logged-in user" do
      logged_in_user = perform_login(users(:kari))
      
      expect {
        delete work_path(existing_work.id)
      }.wont_change "Work.count"

      must_respond_with :redirect
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      expect {
        delete work_path(bogus_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      # Arrange
      work = works(:album)
      before_vote = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      work.reload
      expect(session[:user_id]).must_be_nil
      expect(work.vote_count).must_equal before_vote
      must_redirect_to work_path(work)
    end

    it "redirects to the work page after the user has logged out" do
      skip
      # user logged out and redirect is not related to upvote?
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      # Arrange
      # kari hasn't voted another_album
      user = perform_login(users(:kari))
      work = works(:another_album)
      vote_count = work.vote_count
  
      # Act
      post upvote_path(work)

      # Assert
      work.reload
      expect(session[:user_id]).must_equal user.id
      expect(work.vote_count).must_equal (vote_count + 1)
      must_redirect_to work_path(work)
    end

    it "redirects to the work page if the user has already voted for that work" do
      # Arrange
      # dan already voted album
      user = perform_login(users(:dan))
      work = works(:album)
      before_vote = work.vote_count

      # Act
      post upvote_path(work)

      # Assert
      work.reload
      expect(session[:user_id]).must_equal user.id
      expect(work.vote_count).must_equal before_vote
      must_redirect_to work_path(work)
    end
  end
end
