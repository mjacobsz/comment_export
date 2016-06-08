require 'Faker'

class Post

  attr_accessor :user_email, :text

  def initialize(user_email = nil, text = nil)
    @user_email = user_email
    @text = text
  end

  def to_s
    "\tMAIL: #{@user_email}\n\tTEXT: #{@text}\n"
  end

  def self.gimme_some_posts(n)
    n.times.map do
      new(Faker::Internet::email, Faker::Lorem.paragraphs.join)
    end
  end

end
