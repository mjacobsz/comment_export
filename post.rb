# Objects in this class represent a post entry from the disqus XML export
class Post

  attr_accessor :id, :user_email, :text, :deleted, :created_at

  def initialize(id = nil, user_email = nil, text = nil, deleted = nil, spam = nil, created_at = nil)
    @id =         id
    @text =       text
    @spam =       spam        # This is sometimes true, but I checked those manually. They were not spam, so we won't take any action based on this attribute.
    @deleted =    deleted
    @created_at = created_at
    @user_email = user_email
  end

  def to_s
    "ID: #{@id}
      \tMAIL: #{@user_email}
      \tDELETED: #{@deleted}
      \tSPAM: #{@spam}
      \tCREATED_AT: #{@created_at}
      \tTEXT: #{@text}"
  end

end
