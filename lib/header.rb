# frozen_string_literal: true

require './lib/definitions.rb'
require './lib/models.rb'

MSG_ADDRESS_SUFFIX = 'line.message'
MSG_ID_SUFFIX = 'line.message.id'

def get_message_id(msg)
  return "<#{msg[:server_id] || msg[:created_time]}@#{MSG_ID_SUFFIX}>"
end

def get_message_from(msg, me)
  if !msg[:from_mid]
    return get_sent_message_from(msg, me)
  else
    return get_recv_message_from(msg, me)
  end
end

def get_message_to(msg, me)
  members = []
  room = ChatRoom.find_by(chat_id: msg[:chat_id])
  case room&.[](:type)
  when ChatType::PERSONAL, nil
    status = get_user_status(msg[:from_mid] || msg[:chat_id])
    members.push "\"#{status.sender}\" <#{status.address}@#{MSG_ADDRESS_SUFFIX}>" if status
  when ChatType::MULTIPLE
    ChatMember.where('chat_id=?', msg[:chat_id]).map do |mem|
      if mem[:mid] != msg[:from_mid]
        status = get_user_status(mem[:mid])
        members.push "\"#{status.sender}\" <#{status.address}@#{MSG_ADDRESS_SUFFIX}>" if status
      end
    end  
  when ChatType::GROUP
    Membership.where('id=?', msg[:chat_id]).map do |mem|
      if mem[:mid] != msg[:from_mid]
        status = get_user_status(mem[:mid])
        members.push "\"#{status.sender}\" <#{status.address}@#{MSG_ADDRESS_SUFFIX}>" if status
      end
    end  
  end
  if !msg[:from_mid].nil?
    members.push "\"#{me.sender}\" <#{me.address}@#{MSG_ADDRESS_SUFFIX}>"
  end
  return members
end

def get_message_subject(msg)
  room = ChatRoom.find_by(chat_id: msg[:chat_id])
  if room&.[](:type) == ChatType::GROUP
    return Group.where('id=?', msg[:chat_id])&.first&.[](:name)
  else
    return nil
  end
end

def save_lastmessage(conf, msg, mail)
  conf.last_message_id_dic[msg[:chat_id]] = \
    "<#{mail.message_id}>".sub(/^<</,'<').sub(/>>$/,'>')
end

private

def get_recv_message_from(msg, _me)
  status = get_user_status(msg[:from_mid])
  if status.nil?
    return "<nil@#{MSG_ADDRESS_SUFFIX}>"
  else
    return "\"#{status.sender}\" <#{status.address}@#{MSG_ADDRESS_SUFFIX}>"
  end
end

def get_sent_message_from(_msg, me)
  return "\"#{me.sender}\" <#{me.address}@#{MSG_ADDRESS_SUFFIX}>"
end

def get_info_message_from(_msg, _me)
  return "\"Info\" <info@#{MSG_ADDRESS_SUFFIX}>"
end

def get_user_status(id)
  usr = User.find_by(m_id: id)
  return nil if usr.nil?
  status = UserStatus.new
  status.sender = [usr[:custom_name], usr[:name], usr[:addressbook_name]].select { |n| n && n != '' }.join(', ')
  status.address = usr[:m_id]
  return status
end
