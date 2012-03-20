require 'spec_helper'

describe "Authentication" do

	subject { page }

	describe "signin process" do
		before { visit signin_path }

		it { should have_selector('h1',       text: 'Sign In') }
		it { should have_selector('title',    text: 'Sign In') }
        
        describe "should not see profile and settings links when not signed in" do
            let(:user) { FactoryGirl.create(:user) }

            it { should_not have_link('Profile',    href: user_path(user)) }
            it { should_not have_link('Settings',   href: edit_user_path(user)) }
        end

		describe "sign in with invalid credentials" do
			before { click_button "Sign In" }

			it { should have_selector('title', 	text: 'Sign In') }
			it { should have_selector('div.alert.alert-error', 	text: 'invalid') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "sign in with valid credentials" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			it { should have_selector('title', 		text: user.name) }
			it { should have_link('Profile', 		href: user_path(user)) }
			it { should have_link('Sign Out', 		href: signout_path) }
			it { should_not have_link('Sign In', 	href: signin_path) }

            describe "signed in users have no reason to access NEW and CREATE actions in Users controller" do
                before { get new_user_path }
                specify { response.should redirect_to(root_path) }
                before { post users_path }
                specify { response.should redirect_to(root_path) }
            end

			describe "followed by signout" do
				before { click_link "Sign Out" }
				it { should have_link('Sign In') }
			end
		end
	end

	describe "what happens when you edit user with valid information" do 
		let(:user) {FactoryGirl.create(:user)}
		before { sign_in user }

		it { should have_selector('title', 		text: user.name) }
        it { should have_link('Users',          href: users_path) }
		it { should have_link('Profile', 		href: user_path(user)) }
		it { should have_link('Settings', 		href: edit_user_path(user)) }
		it { should have_link('Sign Out', 		href: signout_path) }
		it { should_not have_link('Sign In', 		href: signin_path) }
    end

    describe "authorization actions" do
    	describe "what happens to non-signed in users" do
    		let(:user) {FactoryGirl.create(:user) }

    		describe "in the Users controller" do
    			
    			describe "what happens when attempting to visit the protected edit user page" do
    				before { visit edit_user_path(user) }
    				it { should have_selector('title', 		tex: 'Sign In') }
    			end

    			describe "redirect to protected edit user page AFTER you validly sign in" do
    				before { visit edit_user_path(user) }
                    before { sign_in user }

    				it { should have_selector('title', 		text: "Edit User") }

				end    			

    			describe "what happens when actually trying to update a user" do
    				before { put user_path(user) }
    				specify { response.should redirect_to(signin_path) }
    			end

    			describe "non-signed in users who attempt to access the user index" do
    				before { visit users_path }
    				it { should have_selector('title', 		text: 'Sign In') }
    			end

                describe "when non-signed in user tries to CREATE micropost" do
                    before { post microposts_path }
                    specify { response.should redirect_to(signin_path) } 
                end

                describe "when non-signed in user tries to DESTROY micropost" do
                    before do 
                        micropost = FactoryGirl.create(:micropost)
                        delete micropost_path(:micropost)
                    end
                    
                    specify { response.should redirect_to(signin_path) } 
                end
    		end
    	end

    	describe "what happens when wrong user tries to edit another user's profile" do
    		let(:user) { FactoryGirl.create(:user) }
    		let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
    		before { sign_in user }

    		describe "what happens when visiting Users#edit page" do
    			before { visit edit_user_path(wrong_user) }
    			it { should have_selector('title', 		text: full_title('')) }
    		end

    		describe "what happens when submitting a PUT request to User#update action" do
    			before { put user_path(wrong_user) }
    			specify { response.should redirect_to(root_path) }
    		end
    	end

        describe "restrictions on non-admin users" do
            let(:user) { FactoryGirl.create(:user) }
            let(:non_admin) { FactoryGirl.create(:user) }

            before { sign_in non_admin }

            describe "non-admin cannot submit DELETE request to Users#destroy action" do
                before { delete user_path(user) }
                specify { response.should redirect_to(root_path) }
            end
        end
    end
end
