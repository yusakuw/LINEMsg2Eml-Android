# frozen_string_literal: true

module ChatType
  PERSONAL = 1
  MULTIPLE = 2
  GROUP = 3
end

module ContentType
  MESSAGE  = 1
  UNKNOWN2 = 2
  UNKNOWN3 = 3
  PHONE  = 4
  STICKER = 5
  UNKNOWN6 = 6
  MEDIA_PREVIEW = 8
  UNKNOWN9 = 9
  UNKNOWN13 = 13
  UNKNOWN16 = 16
  UNKNOWN17 = 17
  UNKNOWN27 = 27
end

module AttachmentType
  TEXT = 0
  IMAGE = 1
  MOVIE = 2
  HTML = 4
  PHONE = 6
  STICKER = 7
  FILE = 14
  MEDIA_PREVIEW = 16
  ADBANNER = 17
  UNKNOWN18 = 18
  FLEX_MESSAGE = 22
end

# $backup_root_dir: String
