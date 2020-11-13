# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'net/https'

require './lib/models.rb'

def get_sticker_data(stkver, stkopt, stkid, stkpkgid)
  base_uri = "https://dl.stickershop.line.naver.jp/products/0/0/#{stkver}/#{stkpkgid}"
  info_uri = base_uri + '/iphone/productInfo.meta'
  sticker_uri =  base_uri + "/iphone/stickers/#{stkid}@2x.png"
  animation_uri = base_uri + "/iphone/animation/#{stkid}@2x.png"
  sound_uri = base_uri + "/iphone/sound/#{stkid}.m4a"

  data = {}
  begin
    data['sticker'] = URI.open(sticker_uri, 'rb', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    info = JSON.load(URI.open(info_uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)
    if info['hasAnimation']
      data['animation'] = URI.open(animation_uri, 'rb', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
    if info['hasSound']
      data['sound'] = URI.open(sound_uri, 'rb', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    end
  rescue
  end
  return data # {'sticker': png or nil, 'animation': apng or nil, 'sound': m4a or nil}
end
