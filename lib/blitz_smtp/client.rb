class BlitzSMTP::Client

  def initialize(address, port)
    @server_address, @server_port = address, port
  end

  class AlreadyConnected < StandardError; end

  def connect
    raise AlreadyConnected if connected?
    @socket = TCPSocket.open @server_address, @server_port
    wait_for_protocol_start
  end

  class NotConnected < StandardError; end

  def disconnect
    raise NotConnected unless connected?
    send_quit
    @socket.close
    @socket = nil
  end

  def connected?
    not @socket.nil?
  end

  protected

  def send_quit
    @socket.puts "QUIT"
    @socket.gets
  end

  def wait_for_protocol_start
    @socket.gets
  end

end
