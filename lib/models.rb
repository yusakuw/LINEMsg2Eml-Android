# frozen_string_literal: true

require 'active_record'

UserStatus = Struct.new(:sender, :address)

class LineDb < ActiveRecord::Base
  self.inheritance_column = nil
  establish_connection(
    adapter: 'sqlite3',
    database: "#{$backup_root_dir}/naver_line"
  )
end

class ChatRoom < LineDb
  self.table_name = :chat
  self.primary_key = :chat_id
end

class ChatMember < LineDb
  self.table_name = :chat_member
end

class Membership < LineDb
  self.table_name = :membership
end

class Group < LineDb
  self.table_name = :groups
  self.primary_key = :id
end

class Message < LineDb
  self.table_name = :chat_history
  self.primary_key = :id
end

class User < LineDb
  self.table_name = :contacts
end

class Sticker < LineDb
  self.table_name = :sticker
end

class StickerPackage < LineDb
  self.table_name = :stickerpackage
end
