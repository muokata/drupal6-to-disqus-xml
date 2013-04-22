# encoding: UTF-8
require 'builder'

def create_file
  $file = File.new("disqusxml-#{$file_counter}.xml", "w+")
  open_xml
  $file_counter += 1
end

def close_file
  close_thread
  close_xml
end

def open_xml
  string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:dsq="http://www.disqus.com/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:wp="http://wordpress.org/export/1.0/"
>
<channel>
XML

  $file.puts string
end

def close_xml
  string = <<-XML
</channel>
</rss>
XML

  $file.puts string
end

def open_thread(comment)
  post_date_gmt = Time.at(comment[:created]).utc.to_s
  post_date_gmt.slice! " UTC"
  
  comment_url = comment[:bricolage_template]
  comment_url.gsub!(/index.html/, '')

  string = <<-XML
<item>
  <title>#{comment[:title]}</title>
  <link>http://dev.thetyee.anarres.ca/#{comment_url}</link>
  <content:encoded><![CDATA[#{comment[:title]}]]></content:encoded>
  <dsq:thread_identifier>#{comment[:bricolage_template]}</dsq:thread_identifier>
  <wp:post_date_gmt>#{post_date_gmt}</wp:post_date_gmt>
  <wp:comment_status>open</wp:comment_status>
XML

  $file.puts string
end

def close_thread
  $file.puts "</item>"
end

def add_comment(comment)
  post_date_gmt = Time.at(comment[:timestamp]).utc.to_s
  post_date_gmt.slice! " UTC"
 
  # get rid of some unwanted content in the body 
  comment_body = comment[:comment]
 
  comment_body.gsub!(/\[\/?(?:b|u|i|s|B|U|I|S|quote|QUOTE|url|URL|email|EMAIL)(?:=[^\]\s]+)?\]/, '')
 
  #remove embeded youtube
  comment_body.gsub!(/\[youtube\].*?\[\/youtube\]/, '')
   
  #remove evernything within [img] ... [/img] bbcode... clarify
  #comment_body.gsub!(/\[img\].*?\[\/img\]/, '')
  #comment_body.gsub!(/\[IMG\].*?\[\/IMG\]/, '')
  
  #remove <ctrl>M
  comment_body.delete!("\C-M") 

  #fix Latin-1 UTF-8 encoding issues. an old export of content/databse/cms has Latin-1
  #encoded caracters, newer content is all UTF-8, they are mixed. this mess below
  #is the only thing i coud get to work...

  comment_body.gsub!(/â€”/, '-')
  comment_body.gsub!(/â€“/, '-')
  comment_body.gsub!(/â€¦/, '…')
  comment_body.gsub!(/â€™/, '’')
  comment_body.gsub!(/â€˜/, '‘')
  comment_body.gsub!(/â€œ/, '“')
  comment_body.gsub!(/â€¢/, '•')
  comment_body.gsub!(/â„¢/, '™')
  comment_body.gsub!(/â€[[:cntrl:]]/, '”')
  comment_body.gsub!(/â€/, '†')
  comment_body.gsub!(/â‚¬/, '€')

  comment_body.gsub!(/Ã©/, 'é')
  comment_body.gsub!(/Ãª/, 'ê')
  comment_body.gsub!(/Ã¨/, 'è')
  comment_body.gsub!(/Ã§/, 'ç')
  comment_body.gsub!(/Ã¸/, 'ø')
  comment_body.gsub!(/Ã¼¸/, 'ü')
  comment_body.gsub!(/Ã±¸/, 'ñ')
  comment_body.gsub!(/Ã¡/, 'á')
  comment_body.gsub!(/Ã¯/, 'ï')
  comment_body.gsub!(/Ãˆ/, 'ï')
  comment_body.gsub!(/Ã˜/, 'Ø')
  comment_body.gsub!(/Ã‰/, 'É')
  comment_body.gsub!(/Ã…/, '…')
  comment_body.gsub!(/Ã‹/, 'Ë')
  comment_body.gsub!(/ÃŒ/, 'Ì')
  comment_body.gsub!(/Ã¶/, 'ö')
  comment_body.gsub!(/Ã‡/, 'Ç')
  comment_body.gsub!(/Ã¤/, 'ä')
  comment_body.gsub!(/Ã³/, 'ó')
  comment_body.gsub!(/Ã¼/, 'ü')
  comment_body.gsub!(/Ã‚/, 'Â')
  comment_body.gsub!(/Ã£/, 'ã')
  comment_body.gsub!(/Ã«/, 'ë')
  comment_body.gsub!(/Ãº/, 'ú')
  comment_body.gsub!(/Ã©/, 'é')
  comment_body.gsub!(/Ã¬/, 'ì')
  comment_body.gsub!(/Â¢/, '¢')
  comment_body.gsub!(/Ã¥/, 'å')
  comment_body.gsub!(/Ã‘/, 'Ñ')
 
  comment_body.gsub!(/Â©/, '©')
  comment_body.gsub!(/Â®/, '®')
  comment_body.gsub!(/Â½/, '½')
  comment_body.gsub!(/Â¾/, '¾')
  comment_body.gsub!(/Â¼/, '¼')
  comment_body.gsub!(/Â±/, '±')
  comment_body.gsub!(/Â³/, '³')
  comment_body.gsub!(/Â²/, '²')
  comment_body.gsub!(/Â¹/, '¹')
  comment_body.gsub!(/Â´/, '´')
  comment_body.gsub!(/Â¯/, '¯')
  comment_body.gsub!(/Â°/, '°')
  comment_body.gsub!(/Âª/, 'ª')
  comment_body.gsub!(/Â»/, '»')
  comment_body.gsub!(/Â«/, '«')
  comment_body.gsub!(/Â·/, '·')
  comment_body.gsub!(/Â¿/, '¿')
  comment_body.gsub!(/Â¶/, '¶')
  comment_body.gsub!(/Â£/, '£')
  comment_body.gsub!(/Ã¢/, 'â')
  comment_body.gsub!(/Â¡/, '¡')
  comment_body.gsub!(/Â­/, '')
  comment_body.gsub!(/Â¦/, '¦')
  comment_body.gsub!(/Â¨/, '¨')
  comment_body.gsub!(/Â¸/, '¸')
  comment_body.gsub!(/Â¤/, '¤')
  comment_body.gsub!(/Âµ/, 'µ')
  comment_body.gsub!(/Â§/, '§')
  comment_body.gsub!(/Â\*/, '')
  comment_body.gsub!(/Â/, '')
  comment_body.gsub!(/D\`ME/, 'D`ÂME')
 
  #this does not work
  #comment_body.force_encoding("ISO-8859-1").encode("UTF-8") 
  
  string = String.new
  xml = Builder::XmlMarkup.new(:target => string)

  xml.wp :comment do |x|
    x.wp :comment_id, comment[:cid]
    x.wp :comment_author, comment[:name]
    x.wp :comment_author_email, comment[:mail]
    x.wp :comment_author_url, comment[:homepage]
    x.wp :comment_author_IP, comment[:hostname]
    x.wp :comment_date_gmt, post_date_gmt
    x.wp :comment_content do |cd|
      cd.cdata!(comment_body)
    end
    x.wp :comment_approved, 1
    x.wp :comment_parent, 0
  end

  $last_nid = comment[:nid]
  $file.puts string
end
