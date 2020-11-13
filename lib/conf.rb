# frozen_string_literal: true

require 'yaml'
require './lib/models.rb'

class Conf
  FILENAME = 'linebackup.yml'
  attr_accessor :my_status, :last_message_ids, :latest_timestamp

  def initialize
    if File.exist? FILENAME
      read
    else
      @my_status = UserStatus.new('mysender', 'myaddress')
      @last_message_ids = {}
      @latest_timestamp = 0
      YAML.dump(self, File.open(FILENAME, 'w')) unless File.exist?(FILENAME)
    end
  end

  def read
    replace YAML.load_file(FILENAME)
  end

  def replace(new)
    @my_status = new.my_status
    @last_message_ids = new.last_message_ids
    @latest_timestamp = new.latest_timestamp
  end

  def write
    File.open(FILENAME, 'w') do |e|
      YAML.dump(self, e)
    end
  end

  def save_lastmessage(msg, mail)
    @last_message_ids[msg[:chat_id]] = "<#{mail.message_id}>".sub(/^<</,'<').sub(/>>$/,'>')

    if @latest_timestamp >= msg[:created_time].to_i
      puts "NOTICE: @latest_timestamp = #{@latest_timestamp}, msg[:created_time] = #{msg[:created_time]}"
    end
    @latest_timestamp = msg[:created_time].to_i
    write
  end
end
