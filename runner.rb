require 'nokogiri'
require 'byebug'
require 'json'

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

class Post

  attr_accessor :user_email, :text, :created_at

  def initialize(user_email = nil, text = nil, created_at = nil)
    @user_email = user_email
    @text = text
    @created_at = created_at
  end

  def to_s
    "\tMAIL: #{@user_email}\n\tTEXT: #{@text}\nCREATED_AT: #{@created_at}"
  end

end

handle = File.open(ARGV[0])
doc =  Nokogiri::XML(handle)
ns = doc.namespaces

threads = {}

doc.xpath('/xmlns:disqus/xmlns:post', ns).each do |nokogiri_post|
  text       = nokogiri_post.xpath('./xmlns:message', ns).text
  email      = nokogiri_post.xpath('./xmlns:author/xmlns:email', ns).text
  created_at = nokogiri_post.xpath('./xmlns:createdAt', ns).text

  post = Post.new(email, text, created_at)

  thread_id = nokogiri_post.at_xpath('./xmlns:thread', ns).attributes["id"].value

  if (!threads[thread_id])
    thread_node = doc.xpath("/xmlns:disqus/xmlns:thread[@dsq:id=#{thread_id}]", ns)
    link = thread_node.xpath('./xmlns:link').text
    threads[thread_id] = MCThread.new(link, thread_id)
  end

  threads[thread_id] << post
end

File.open("bout.json","w") do |f|
  threads.each { |t|
    f.puts(t)
  }
end

