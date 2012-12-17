module BlitzSMTP
  class Client

    class AlreadyConnected < StandardError; end
    class EHLOUnsupported < StandardError; end
    class PipeliningUnsupported < StandardError; end
    class NotConnected < StandardError; end

    def initialize(address, port)
      @server_address, @server_port = address, port
    end

    def connect
      raise AlreadyConnected if connected?
      @socket = TCPSocket.open @server_address, @server_port
      read_response # ignore actual response FIXME
      check_features
    rescue
      disconnect if connected?
      raise
    end

    def disconnect
      raise NotConnected unless connected?
      send_command "QUIT"
      read_response
      @socket.close
      @socket = nil
    end

    def connected?
      not @socket.nil?
    end

    def send_message(from, to, message)
      send_command "MAIL", "FROM:#{format_address(from)}"
      send_command "RCPT", "TO:#{format_address(to)}"
      send_command "DATA"
      3.times { read_response }
      send_data message
      read_response
    end

    protected

    def format_address(address)
      if address =~ /<.*>/
        address
      else
        "<#{address}>"
      end
    end

    def send_data(message)
      Data.new(message).write_to(@socket)
    end

    def send_command(*args)
      command = Command.create(*args)
      command.write_to(@socket)
    end

    def read_response
      Response.new.read_from(@socket)
    end

    def read_extended_response
      responses = []
      loop do
        responses << read_response
        break unless responses.last.continued?
      end
      responses
    end

    def check_features
      send_command "EHLO localhost"
      responses = read_extended_response
      unless responses.first.status_code == 250
        raise(EHLOUnsupported, "the server must implement RFC2920")
      end
      unless responses.any? { |r| r.message == "PIPELINING" }
        raise(PipeliningUnsupported, "the server must implement RFC2920")
      end
    end
  end
end
