# BlitzSmtp

BlitzSMTP implements RFC2920 (Command Pipelining) to achieve high
message throughput. It is no replacement for Net::SMTP, it's just
faster.

## Installation

Add this line to your application's Gemfile:

    gem 'blitz_smtp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blitz_smtp

## Usage
```ruby
smtp = BlitzSMTP.new(address, port)
    
# open the connection
smtp.connect
    
# after opening the connection you can send messages
smtp.send_message "mail@from.com", "mail@to.com", <<-EOM
Subject: Hi
    
Hello world
EOM
smtp.send_message "mail@from.com", "other@to.com", <<-EOM
Subject: Hey
    
You too
EOM
    
# when you're done close the connection
smtp.disconnect
```
