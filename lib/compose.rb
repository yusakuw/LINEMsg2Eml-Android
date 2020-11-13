# frozen_string_literal: true

require 'open-uri'

require './lib/models.rb'
require './lib/sticker.rb'
require './lib/definitions.rb'
require './lib/flex_message.rb'

def compose_text_content(msg, mail)
  # TODO: convert some codes into LINE emoji
  # https://developers.line.me/media/messaging-api/emoji-list.pdf

  param = get_parameter_info(msg[:parameter])
  mail.text_part do
    body "#{msg[:content]}\n"
    content_type 'text/plain; charset=UTF-8'
  end  
return mail
end

def compose_file_message_content(msg, mail)
  param = get_parameter_info(msg[:parameter])
  mail.text_part do
    body "FILE_NAME: #{param['FILE_NAME']}\n"
    content_type 'text/plain; charset=UTF-8'
  end  
return mail
end


def compose_image_content(msg, mail)
  param = get_parameter_info(msg[:parameter])

  if param['DOWNLOAD_URL']
    begin
      URI.open(param['DOWNLOAD_URL'], 'rb') do |io|
        mail.attachments[File.basename(URI.parse(param['DOWNLOAD_URL']).path) + '.jpg'] = io.read
      end
    rescue
    end
  end

  mail.text_part do
    body "[画像]\n#{msg[:content]}\n\n#{msg[:attachement_local_uri]}\n#{msg[:parameter]}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end

def compose_movie_content(msg, mail)
  param = get_parameter_info(msg[:parameter])

  if param['DOWNLOAD_URL']
    begin
      URI.open(param['DOWNLOAD_URL'], 'rb') do |io|
        mail.attachments[File.basename(URI.parse(param['DOWNLOAD_URL']).path) + '.mp4'] = io.read
      end
    rescue
    end
  end
  mail.text_part do
    body "[動画]\n#{msg[:content]}\n\n#{msg[:parameter]}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end

def compose_html_content(msg, mail)
  param = get_parameter_info(msg[:parameter])
  html = Nokogiri::HTML.parse(param['HTML_CONTENT'])
  if html.at_css('body')['style']
    html.at_css('body')['style']=html.at_css('body')['style'].gsub(/opacity: ?0/, '')
  end
  mail.text_part do
    body "#{param['ALT_TEXT']}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  mail.html_part = Mail::Part.new do
    content_type 'text/html; charset=UTF-8'
    body html.to_s
  end
  return mail
end

def compose_flex_message_content(msg, mail)
  param = get_parameter_info(msg[:parameter])
  html = generate_flex_message(param['FLEX_JSON'])
  mail.text_part do
    body "#{param['ALT_TEXT']}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  mail.html_part = Mail::Part.new do
    content_type 'text/html; charset=UTF-8'
    body html.to_html
  end
  return mail
end

def compose_phone_content(msg, mail)
  mail.text_part do
    body "電話がありました。\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end

def get_parameter_info(param_raw)
  return nil if param_raw == nil
  return param_raw.split("\t").each_slice(2).map { |a, b| [a, b] }.to_h
end

def compose_sticker_content(msg, mail)
  param = get_parameter_info(msg[:parameter])
  data = get_sticker_data(param['STKVER'], param['STKOPT'], param['STKID'], param['STKPKGID'])
  mail.attachments['sticker.png'] = data['sticker'] if data['sticker']
  mail.attachments['animation.png'] = data['animation'] if data['animation']
  mail.attachments['sound.m4a'] = data['sound'] if data['sound']
  mail.text_part do
    body "#{param['STKTXT']}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end

def compose_adbanner_content(msg, mail)
  param = get_parameter_info(msg[:parameter])
  begin
    URI.open(param['DOWNLOAD_URL'], 'rb') do |io|
      mail.attachments[File.basename(URI.parse(param['DOWNLOAD_URL']).path) + '.jpg'] = io.read
    end
  rescue
  end
  mail.text_part do
    body "#{param['ALT_TEXT']}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end


def compose_text_withparaminfo_content(msg, mail)
  mail.text_part do
    body "#{msg[:content]}\n\n#{msg[:parameter]}\n"
    content_type 'text/plain; charset=UTF-8'
  end
  return mail
end


def compose_content(msg, mail)
  case msg[:type]
  when ContentType::MESSAGE
    case msg[:attachement_type]
    when AttachmentType::TEXT
      mail = compose_text_content(msg, mail)
    when AttachmentType::HTML
      mail = compose_html_content(msg, mail)
    when AttachmentType::ADBANNER
      mail = compose_adbanner_content(msg, mail)
    when AttachmentType::FLEX_MESSAGE
      mail = compose_flex_message_content(msg, mail)
    when AttachmentType::FILE
      mail = compose_file_message_content(msg, mail)
    when AttachmentType::MOVIE
      mail = compose_movie_content(msg, mail)
    when AttachmentType::IMAGE
      mail = compose_image_content(msg, mail)
    else
      p "unknown AttachmentType: #{msg[:attachement_type]}"
      mail = compose_text_withparaminfo_content(msg, mail)
    end
  when ContentType::PHONE
    mail = compose_phone_content(msg, mail)
  when ContentType::STICKER
    mail = compose_sticker_content(msg, mail)
  else
    mail = compose_text_withparaminfo_content(msg, mail)
  end
  return mail
end
