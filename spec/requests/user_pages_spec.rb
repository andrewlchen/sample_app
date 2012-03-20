require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign Up') }
    it { should have_selector('title', text: full_title('Sign Up')) }
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
    let!(:micropost1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:micropost2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
  	before { visit user_path(user) }

  	it { should have_selector('h1', 	text: user.name) } 
  	it { should have_selector('title', 	text: user.name) } 

    describe "how microposts appear on profile page" do
      it { should have_content(micropost1.content) }
      it { should have_content(micropost2.content) }
      it { should have_content(user.microposts.count) }
    end
  end

  describe "signup process" do
    before { visit signup_path }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button "Create my account" }.not_to change(User, :count) 
      end

      describe "error messages" do
        before { click_button "Create my account" }

        it { should have_selector('title', text: 'Sign Up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do 
        fill_in "Name",         with: "Example User"
        fill_in "E-mail",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect {click_button "Create my account"}.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button "Create my account" }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign Out') }
      end
    end
  end

  describe "edit user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }
    before { visit edit_user_path(user) }

    describe "the edit user page" do
      it { should have_selector('h1',     text: "Update your profile") }
      it { should have_selector('title',  text: "Edit User") }
      it { should have_link('Change photo',   href: 'http://gravatar.com/emails') }
    end

    describe "what happens when you edit user with invalid information" do
      before { click_button "Save Changes" }

      it { should have_content('error') }
    end

    describe "what happens when you edit user with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "E-mail",           with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save Changes"
      end

      it { should have_selector('title',    text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign Out',     href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

describe "access index page" do
  before do
    sign_in FactoryGirl.create(:user)
    FactoryGirl.create(:user, name: "Bob Boy", email: "bob@example.com")
    FactoryGirl.create(:user, name: "Ben Baby", email: "ben@example.com")
    visit users_path
  end

  it { should have_selector('title',      text: 'All Users') }

  it "should list all users" do 
      User.all.each do |user|
        page.should have_selector('li',     text: user.name)
      end
  end

  describe "pagination" do 
    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all) { User.delete_all }

    it { should have_link('Next') }
    it { should have_link('2') }
    it "should list each user" do
      User.all[0..2].each do |user|
          page.should have_selector('li',   text: user.name)
      end
    end

    it { should_not have_link('delete') }

    describe "what you see as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin }
      before { visit users_path }

      it { should have_link('Delete',       href: user_path(User.first)) }
      it "admin should be able to delete another user" do
        expect { click_link('Delete') }.to change(User, :count).by(-1)
      end
      it { should_not have_link('delete',   href: user_path(admin)) }
    end
  end
end

end