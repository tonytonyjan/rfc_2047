# Copyright (c) 2020 Jian Weihang <tonytonyjan@gmail.com>
# frozen_string_literal: true

require 'minitest/autorun'
require 'rfc_2047'

class Test < Minitest::Test
  def assert_encode(expected, input, **options)
    assert_equal expected, Rfc2047.encode(input, **options)
  end

  def assert_decode(expected, input)
    assert_equal expected, Rfc2047.decode(input)
  end
end

class TestRfc2047 < Test
  def test_encode
    assert_equal '=?UTF-8?B?5ris6Kmm?=', Rfc2047.encode('測試')
  end

  def test_decode
    assert_equal 'this is some text', Rfc2047.decode('=?iso-8859-1?q?this=20is=20some=20text?=')
    assert_equal '測試', Rfc2047.decode('=?UTF-8?B?5ris6Kmm?=')
  end

  class Base64 < Test
    def test_it_should_decode_an_encoded_string
      assert_decode(
        'This is あ string',
        '=?UTF-8?B?VGhpcyBpcyDjgYIgc3RyaW5n?='
      )
    end

    def test_it_should_decode_a_long_encoded_string
      assert_decode(
        'This is あ really long string This is あ really long string This is あ really long string This is あ really long string This is あ really long string',
        '=?UTF-8?B?VGhpcyBpcyDjgYIgcmVhbGx5IGxvbmcgc3RyaW5nIFRoaXMgaXMg44GCIHJl?= =?UTF-8?B?YWxseSBsb25nIHN0cmluZyBUaGlzIGlzIOOBgiByZWFsbHkgbG9uZyBzdHJp?= =?UTF-8?B?bmcgVGhpcyBpcyDjgYIgcmVhbGx5IGxvbmcgc3RyaW5nIFRoaXMgaXMg44GC?= =?UTF-8?B?IHJlYWxseSBsb25nIHN0cmluZw==?='
      )
    end

    def test_it_should_decode_utf_16_encoded_string
      assert_decode(
        'あいうえお',
        '=?UTF-16?B?MEIwRDBGMEgwSg==?='
      )
    end

    def test_it_should_decode_utf_32_encoded_string
      assert_decode(
        'あいうえお',
        '=?UTF-32?B?AAAwQgAAMEQAADBGAAAwSAAAMEo=?='
      )
    end

    def test_it_should_decoded
      assert_decode(
        '案件情報[-01 大手資産運用会社 - 資産運用にかかるDWHの二次開発業務]',
        "=?iso-2022-jp?Q?=1B=24B0F7o=3EpJs=1B=28B=5B=2D01_=1B=24?=\n =?iso-2022-jp?Q?BBg=3Cj=3Bq=3B=3A1=3FMQ2q=3CR=1B=28B_=2D_=1B=24B=3B?=\n =?iso-2022-jp?Q?q=3B=3A1=3FMQ=24K=24=2B=24=2B=24k=1B=28BDWH=1B=24B=24?=\n =?iso-2022-jp?Q?NFs=3C=213=2BH=2F6HL3=1B=28B=5D?="
      )
    end

    def test_it_should_decode_a_string_that_looks_similar_to_an_encoded_string
      assert_decode('1+1=?', '1+1=?')
    end

    def test_it_should_parse_adjacent_encoded_words_separated_by_linear_white_space
      assert_decode(
        'новый сотрудник — дорофеев',
        "=?utf-8?B?0L3QvtCy0YvQuSDRgdC+0YLRgNGD0LTQvdC40Log4oCUINC00L7RgNC+0YQ=?=\n =?utf-8?B?0LXQtdCy?="
      )
    end

    def test_it_should_parse_adjacent_words_with_no_space
      assert_decode(
        'новый сотрудник — дорофеев',
        '=?utf-8?B?0L3QvtCy0YvQuSDRgdC+0YLRgNGD0LTQvdC40Log4oCUINC00L7RgNC+0YQ=?==?utf-8?B?0LXQtdCy?='
      )
    end

    def test_it_should_collapse_adjacent_words_with_multiple_encodings_on_one_line_seperated_by_non_spaces
      assert_decode(
        "Re:[グルーポン・ジャパン株式会社] 返信：【グルーポン】お問い合わせの件について（リクエスト#1056273\n ）",
        "Re:[=?iso-2022-jp?B?GyRCJTAlayE8JV0lcyEmJTglYyVRJXMzdDwwMnEbKEI=?=\n =?iso-2022-jp?B?GyRCPFIbKEI=?=] =?iso-2022-jp?B?GyRCSlY/LiEnGyhC?=\n  =?iso-2022-jp?B?GyRCIVolMCVrITwlXSVzIVskKkxkJCQ5ZyRvJDsbKEI=?=\n =?iso-2022-jp?B?GyRCJE43byRLJEQkJCRGIUolaiUvJSglOSVIGyhC?=#1056273\n =?iso-2022-jp?B?GyRCIUsbKEI=?="
      )
    end

    def test_it_should_decode_a_blank_string
      assert_decode('', '=?utf-8?B??=')
    end

    def test_it_should_decode_ks_c_5601_1987_encoded_string
      assert_decode(
        '김 현진 <a@b.org>',
        '=?ks_c_5601-1987?B?seggx/bB+A==?= <a@b.org>'
      )
    end

    def test_it_should_decode_shift_jis_encoded_string
      assert_decode('日本語', '=?shift-jis?Q?=93=FA=96{=8C=EA?=')
    end

    def test_it_should_decode_gb18030_encoded_string_misidentified_as_gb2312
      assert_decode('開', '=?GB2312?B?6V8=?=')
    end

    def test_it_should_decode_a_utf_7_encoded_unstructured_field
      assert_decode(
        '勿以惡小而為之，勿以善小而不為。',
        '=?utf-7?B?5Yu/5Lul5oOh5bCP6ICM54K65LmL77yM5Yu/5Lul5ZaE5bCP6ICM5LiN54K6?= =?utf-7?B?44CC?='
      )
    end
  end

  class QuotedPrintable < Test
    def test_it_should_just_return_the_string_if_us_ascii_and_asked_to_q_encoded_string
      assert_encode('This is a string', 'This is a string')
    end

    def test_it_should_decode_an_encoded_string
      assert_encode(
        '=?UTF-8?Q?This_is_=E3=81=82_string?=',
        'This is あ string',
        encoding: :Q
      )
    end

    def test_it_should_decode_an_encoded_string
      assert_decode(
        'This is あ string',
        '=?UTF-8?Q?This_is_=E3=81=82_string?='
      )
    end

    def test_it_should_decode_q_encoded_5F_as_underscore
      assert_decode(
        'This ­ and_that',
        '=?UTF-8?Q?This_=C2=AD_and=5Fthat?='
      )
    end

    def test_it_should_decode_a_blank_string
      assert_decode('', '=?utf-8?Q??=')
    end

    def test_it_should_decode_8bit_encoded_string
      assert_decode("ALPH\xC3\x89E", '=?8bit?Q?ALPH=C3=89E?=')
    end
  end

  class Mixed < Test
    def test_it_should_decode_an_encoded_string2
      assert_decode(
        'This is あ string This was あ string',
        '=?UTF-8?B?VGhpcyBpcyDjgYIgc3RyaW5n?= =?UTF-8?Q?_This_was_=E3=81=82_string?='
      )
    end
  end
end
