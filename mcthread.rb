class MCThread

  attr_accessor :posts, :link

  def initialize(link = nil, id = nil)
    @link = link
    @id = id
    @posts = []
  end

  def <<(other)
    @posts << other
  end

  def to_s
    "LINK: #{@link}" + "\n" + @posts.map { |post| post.to_s }.join("\n")
  end

end
