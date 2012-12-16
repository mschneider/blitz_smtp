module BlitzSMTP
  class Response

    class Invalid < StandardError; end

    def initialize(string)
      raise Invalid unless string =~ /\r\n$/
      @string = string[0..-3]
    end

    def continued?
      @string[3] == "-"
    end

    def message
      @string[4..-1]
    end

    def status_code
      @string[0..2].to_i
    end
  end
end
