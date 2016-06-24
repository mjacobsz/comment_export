require 'fileutils'
require 'nokogiri'
require 'byebug'
require 'json'
require 'date'
require './mcthread.rb'
require './post.rb'
require './helper.rb'

# You need to be in on this path to run this program
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

# container to store all of 'em treads
threads = {}

# statistics
deleted_values = 0
non_deleted_values = 0
other = 0

# Loop through all posts; create a thread if none exists yet for this post
doc.xpath('/xmlns:disqus/xmlns:post', ns).each do |nokogiri_post|
  id         = nokogiri_post["dsq:id"]
  text       = nokogiri_post.xpath('./xmlns:message', ns).text
  email      = nokogiri_post.xpath('./xmlns:author/xmlns:email', ns).text
  deleted    = nokogiri_post.xpath('./xmlns:isDeleted', ns).text == "true" ? true : false
  spam       = nokogiri_post.xpath('./xmlns:isSpam', ns).text == "true" ? true : false
  created_at = DateTime.parse(nokogiri_post.xpath('./xmlns:createdAt', ns).text)

  deleted ? (deleted_values += 1) : (non_deleted_values += 1)

  post = Post.new(id, email, text, spam, deleted, created_at)

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

