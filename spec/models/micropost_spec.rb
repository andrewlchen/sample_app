require 'spec_helper'

describe Micropost do
	let(:user) { FactoryGirl.create(:user) }
	before { @micropost = user.microposts.build(content: "This is a test micropost.") }

	subject { @micropost }

	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:user) }
	its(:user) { should == user }
	it { should be_valid }

	describe "when user_id is absent" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end

	describe "when micropost content is blank" do
		before { @micropost.content = " " }
		it { should_not be_valid }
	end

	describe "when micropost content exceeds 140 chars" do 
		before { @micropost.content = "a" * 141 }
		it { should_not be_valid }
	end
end
