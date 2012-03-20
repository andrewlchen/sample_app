require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "creating microposts" do
    before { visit root_path }

    describe "attempting to post with invalid information" do

      it "should not create microposts" do
        expect { click_button "Post!" }.should_not change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post!" }
        it { should have_content('error') } 
      end
    end

    describe "attempting to post with valid information" do

      before { fill_in 'micropost_content', with: "This is a test post." }
      it "should create a micropost" do
        expect { click_button "Post!" }.should change(Micropost, :count).by(1)
      end
    end
  end

  describe "destroying microposts" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "if current user == micropost poster" do
      before { visit root_path }

      it "should delete micropost" do
        expect { click_link "Delete" }.should change(Micropost, :count).by(-1)
      end
    end
  end
end