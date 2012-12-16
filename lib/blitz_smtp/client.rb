module BlitzSMTP
  class Client

    def initialize(address, port)
      @server_address, @server_port = address, port
    end

    class AlreadyConnected < StandardError; end
    class EHLOUnsupported < StandardError; end
    class PipelingUnsupported < StandardError; end

    def connect
      raise AlreadyConnected if connected?
      @socket = TCPSocket.open @server_address, @server_port
      wait_for_protocol_start
      check_features
    rescue
      disconnect if connected?
      raise
    end

    class NotConnected < StandardError; end

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

    protected

    def send_command(*args)
      command = Command.create(*args)
      command.write_to(@socket)
    end

    def read_response
      Response.read_from(@socket)
    end

    def check_features
      send_command "EHLO localhost"
      responses = []
      loop do
        responses << read_response
        break unless responses.last.continued?
      end
      unless responses.first.status_code == 250
        raise(EHLOUnsupported, "the server must implement RFC2920")
      end
      unless responses.any? { |r| r.message == "PIPELINING" }
        raise(PipelingUnsupported, "the server must implement RFC2920")
      end
    end

    def wait_for_protocol_start
      read_response
    end
  end
end
