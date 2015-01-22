# encoding: UTF-8
require 'sequel'
require 'mysql2'
require 'yaml'
require 'logger'
require File.join(File.expand_path(File.dirname(__FILE__)), '../lib/xml-lib.rb')

config = YAML.load_file File.join(File.dirname(__FILE__), '../config')

# Prepare comments database
db = Sequel.connect(:adapter=>'mysql2', :host=>config['host'], :port=>config['port'], :database=>config['database'], :user=>config['user'], :password=>config['password'], :logger => Logger.new('log/db.log'))
comments = db[:comments]
comments_query = comments.select(:nid, :timestamp, :cid, :name, :mail, :homepage, :hostname, :comment).qualify(:comments).select_append(:title, :created, :type).qualify(:node).exclude(:type => ['forum', 'activist_toolkit']).qualify(:node).filter(:status => 0).qualify(:comments).join(:node, :nid => :nid).reverse(Sequel.desc(:nid)).qualify(:comments)

$file_counter = 0
$last_nid = 0

comments_query.each do |comment|

  if $last_nid == 0
    create_file
    open_thread(comment)
    add_comment(comment)
  end

  if $last_nid > 0 && $last_nid == comment[:nid]
    add_comment(comment)
  end

  if $last_nid != comment[:nid] && $file.size < 45000000
    close_thread
    open_thread(comment)
    add_comment(comment)
  end

  if $last_nid != comment[:nid] && $file.size > 45000000
    close_file
    create_file
    open_thread(comment)
    add_comment(comment)
  end
end

# IMPORTANT: Close file after last comment has been created.
close_file
