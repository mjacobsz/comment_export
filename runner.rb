require 'fileutils'
require 'nokogiri'
require 'byebug'
require 'json'
require 'date'

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

  attr_accessor :user_email, :text, :deleted, :created_at

  def initialize(user_email = nil, text = nil, deleted = nil, created_at = nil)
    @user_email = user_email
    @text = text
    @deleted = deleted
    @created_at = created_at
  end

  def to_s
    "\tMAIL: #{@user_email}\n\tTEXT: #{@text}\nDELETED: #{@deleted}\nCREATED_AT: #{@created_at}"
  end

end

module Helper

  def self.create_new_suffix
    current_max = Dir["results/*"].
      select { |e| e =~ /out/ }.                             # Get only the files in this dir that match our data output file format
      tap    { |e| puts e }.
      map    { |e| e.split(/out|\.json/).last.to_i}.max || 0 # From this set, get the maximum suffix

    new_max = current_max + 1

    raise "\nMAX SUFFIX REACHED: #{new_max}" if new_max > 99

    new_max < 10 ? "0#{new_max}" : new_max.to_s
  end

end


OBLIGATORY_PATH = "/Users/marvin/projects/comment_export"

raise "You should be on this path when running this file: #{OBLIGATORY_PATH}" unless Dir.pwd == OBLIGATORY_PATH

# Open (source) XML file and get namespaces
handle = File.open(ARGV[0])
doc =  Nokogiri::XML(handle)
ns = doc.namespaces

# Logic for (target) output files
output_filename = ARGV[1] || "results/out.json"

# backup old outfile
if File.file?("results/out.json")
  new_filename = "results/out" + Helper::create_new_suffix + ".json"
  FileUtils.cp "results/out.json", new_filename
end

threads = {}

deleted_values = 0
non_deleted_values = 0
other = 0

doc.xpath('/xmlns:disqus/xmlns:post', ns).each do |nokogiri_post|
  text       = nokogiri_post.xpath('./xmlns:message', ns).text
  email      = nokogiri_post.xpath('./xmlns:author/xmlns:email', ns).text
  deleted    = nokogiri_post.xpath('./xmlns:isDeleted', ns).text == "true" ? true : false
  created_at = DateTime.parse(nokogiri_post.xpath('./xmlns:createdAt', ns).text)

  deleted ? (deleted_values += 1) : (non_deleted_values += 1)

  post = Post.new(email, text, deleted, created_at)

  thread_id = nokogiri_post.at_xpath('./xmlns:thread', ns).attributes["id"].value

  if (!threads[thread_id])
    thread_node = doc.xpath("/xmlns:disqus/xmlns:thread[@dsq:id=#{thread_id}]", ns)
    link = thread_node.xpath('./xmlns:link').text
    threads[thread_id] = MCThread.new(link, thread_id)
  end

  threads[thread_id] << post
end

puts "Deleted values: #{deleted_values}"
puts "Non deleted values: #{non_deleted_values}"

File.open(output_filename,"w") do |f|
  threads.each { |t|
    f.puts(t)
  }
end

