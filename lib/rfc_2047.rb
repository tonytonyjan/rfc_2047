# Copyright (c) 2020 Jian Weihang <tonytonyjan@gmail.com>
# frozen_string_literal: true

module Rfc2047
  TOKEN = /[\041\043-\047\052\053\055\060-\071\101-\132\134\136\137\141-\176]+/.freeze
  ENCODED_TEXT = /[\041-\076\100-\176]*/.freeze
  ENCODED_WORD = /=\?(?<charset>#{TOKEN})\?(?<encoding>[QBqb])\?(?<encoded_text>#{ENCODED_TEXT})\?=/.freeze
  ENCODED_WORD_SEQUENCE = /#{ENCODED_WORD}(?:\s*#{ENCODED_WORD})*/.freeze

  class << self
    # example:
    #
    #     Rfc2047.encode('己所不欲，勿施於人。')
    #     # => "=?UTF-8?B?5bex5omA5LiN5qyy77yM5Yu/5pa95pa85Lq644CC?="
    def encode(input, encoding: :B)
      return input if input.ascii_only?

      case encoding
      when :B
        size = 45
        chunks = Array.new(((input.bytesize + size - 1) / size)) { input.byteslice(_1 * size, size) }
        chunks.map! { "=?#{input.encoding}?B?#{[_1].pack('m0')}?=" }.join(' ')
      when :Q
        [input]
          .pack('M').each_line
          .map { "=?#{input.encoding}?Q?#{_1.chomp!.gsub(' ', '_')}?=" }
          .join(' ')
      else raise ":encoding should be either :B or :Q, got #{encoding}"
      end
    end

    # example
    #
    #     Rfc2047.decode '=?UTF-8?B?5Yu/5Lul5oOh5bCP6ICM54K65LmL77yM5Yu/5Lul5ZaE5bCP6ICM5LiN54K6?= =?UTF-8?B?44CC?='
    #     # => "勿以惡小而為之，勿以善小而不為。"
    def decode(input)
      return input unless input.match?(ENCODED_WORD)

      input.gsub(ENCODED_WORD_SEQUENCE) do |match|
        result = +''
        match.scan(ENCODED_WORD) { result << decode_word($&) }
        if result.encoding == Encoding::UTF_7
          result.replace(
            decode_utf7(result.force_encoding(Encoding::BINARY))
          ).force_encoding(Encoding::UTF_8)
        else
          result.encode!(Encoding::UTF_8)
        end
        result
      end
    end

    private

    def decode_word(input)
      match_data = ENCODED_WORD.match(input)
      raise ArgumentError if match_data.nil?

      charset, encoding, encoded_text = match_data.captures
      charset = 'CP950' if charset == 'MS950'

      decoded =
        case encoding
        when 'Q', 'q' then encoded_text.gsub('_', '=20').unpack1('M')
        when 'B', 'b' then encoded_text.unpack1('m')
        end
      found_encoding = find_encoding(charset)
      found_encoding = Encoding::UTF_8 if found_encoding == Encoding::ASCII_8BIT
      decoded.force_encoding(found_encoding)
    end

    def find_encoding(charset)
      case charset.downcase
      when 'utf-16' then Encoding::UTF_16BE
      when 'utf-32' then Encoding::UTF_32BE
      when 'ks_c_5601-1987' then Encoding::CP949
      when 'shift-jis' then Encoding::Shift_JIS
      when 'gb2312' then Encoding::GB18030
      when 'ms950' then Encoding::CP950
      when '8bit' then Encoding::ASCII_8BIT
      when 'latin2' then Encoding::ISO_8859_2
      else Encoding.find(charset)
      end
    end

    # from Net::IMAP
    def decode_utf7(s)
      s.gsub(/&([^-]+)?-/n) do
        if Regexp.last_match(1)
          (Regexp.last_match(1).tr(',', '/') + '===').unpack1('m').encode(Encoding::UTF_8, Encoding::UTF_16BE)
        else
          '&'
        end
      end
    end
  end
end
