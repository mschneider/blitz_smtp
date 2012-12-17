module BlitzSMTP

  class Message

    class Invalid < StandardError; end

    def initialize(string="")
      @string = string
    end

    def to_s
      @string
    end

    def terminator
      "\r\n"
    end

    def write_to(stream)
      #puts "#{stream.local_address.ip_port} << #{"#{self}#{terminator}".inspect}"
      stream.print("#{self}#{terminator}")
    end

    def read_from(stream)
      including_terminator = stream.gets(terminator)
      #puts "#{stream.local_address.ip_port} >> #{(including_terminator).inspect}"
      excluding_terminator = /^(.*)#{terminator}$/.match(including_terminator).to_a.last
      @string = excluding_terminator
      self
    end
  end

  class Command < Message
    def argument
      @string[5..-1]
    end

    def name
      @string[0..3]
    end

    def self.create(name, argument="")
      new("#{name} #{argument}")
    end
  end

  class Data < Message
    def terminator
      "\r\n.\r\n"
    end
  end

  class Response < Message
    def continued?
      @string[3] == "-"
    end

    def message
      @string[4..-1]
    end

    def status_code
      @string[0..2].to_i
    end

    def self.create(status_code, message, continue=false)
      space = continue ? "-" : " "
      new("#{status_code}#{space}#{message}")
    end
  end
end
