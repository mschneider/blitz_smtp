module BlitzSMTP

  class Message

    TERMINATOR = "\r\n"
    class Invalid < StandardError; end

    def initialize(string)
      @string = string
    end

    def to_s
      @string
    end

    def write_to(stream)
      stream.print("#{self}#{TERMINATOR}")
    end

    def self.read_from(stream)
      including_terminator = stream.gets(TERMINATOR)
      excluding_terminator = /^(.*)#{TERMINATOR}$/.match(including_terminator).to_a.last
      new(excluding_terminator)
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
