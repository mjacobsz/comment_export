class Post

  attr_accessor :id, :user_email, :text, :deleted, :created_at

  def initialize(id = nil, user_email = nil, text = nil, deleted = nil, created_at = nil)
    @id = id
    @user_email = user_email
    @text = text
    @deleted = deleted
    @created_at = created_at
  end

  def to_s
    "\tID: #{@id}, MAIL: #{@user_email}\n\tTEXT: #{@text}\nDELETED: #{@deleted}\nCREATED_AT: #{@created_at}"
  end

end
