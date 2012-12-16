class BlitzSMTP::Client

  def initialize(address, port)
    @server_address, @server_port = address, port
  end

  def connect
    @socket = TCPSocket.open @server_address, @server_port
    wait_for_protocol_start
  end

  def disconnect
    send_quit
    @socket.close
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
