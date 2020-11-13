require 'mail'
require 'nokogiri'

require './lib/definitions.rb'

$backup_root_dir = Dir.pwd

require './lib/models.rb'
require './lib/conf.rb'
require './lib/compose.rb'
require './lib/header.rb'

conf = Conf.new

msgs = Message.where('created_time > ?', conf.latest_timestamp).order(created_time: :asc)
msgs.each_with_index do |msg, idx|
  print "\r#{idx + 1}/#{msgs.count}"
  STDOUT.flush

  mail = Mail.new
  mail.charset = 'UTF-8'
  unixtime = msg[:created_time].to_i
  mail.date = Time.at(unixtime / 1000, unixtime % 1000)

  mail.message_id = get_message_id(msg)
  mail.from = get_message_from(msg, conf.my_status)
  mail.to = get_message_to(msg, conf.my_status)
  mail.in_reply_to = conf.last_message_ids[msg[:chat_id]]
  mail.subject = get_message_subject(msg)

  mail = compose_content(msg, mail)

  conf.save_lastmessage(msg, mail)

  File.write("emls/#{msg[:id]}_#{'time' + msg[:created_time]}.eml", mail.to_s)
end
