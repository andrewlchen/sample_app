def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def sign_in(user)
	visit signin_path
	fill_in "E-mail", 		with: user.email
	fill_in "Password", 	with: user.password
	click_button "Sign In"

	# Allow sign in even when not using Capybara
	cookies[:remember_token] = user.remember_token
end