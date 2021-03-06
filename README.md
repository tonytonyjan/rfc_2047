# rfc_2047

It is a Ruby implementation of [RFC 2047][rfc 2047], which is more accurate and fault-tolerant than [ConradIrwin/rfc2047-ruby](https://github.com/ConradIrwin/rfc2047-ruby). The former can encode, decode, and handle charset correctly, while the latter only implement decoding function.

## Installation

```
gem install new_rfc_2047
```

## Usage

```ruby
Rfc2047.encode('己所不欲，勿施於人。')
# => "=?UTF-8?B?5bex5omA5LiN5qyy77yM5Yu/5pa95pa85Lq644CC?="
Rfc2047.decode '=?UTF-8?B?5bex5omA5LiN5qyy77yM5Yu/5pa95pa85Lq644CC?='
# => "己所不欲，勿施於人。"
```

[rfc 2047]: https://www.ietf.org/rfc/rfc2047.txt
