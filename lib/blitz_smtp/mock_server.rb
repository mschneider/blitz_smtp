require 'socket'

class BlitzSMTP::MockServer

  def initialize
    @server_socket = TCPServer.new(address, 0)
    @server_thread = Thread.start do
      @client_socket = @server_socket.accept
      send_greeting
    end
  end

  def address
    "localhost"
  end

  def port
    @server_socket.addr[1]
  end

  def connected_to_client?
    not @client_socket.nil?
  end

  def shutdown!
    @server_thread.kill
    @client_socket.close if connected_to_client?
    @server_socket.close
  end

  protected

  def send_greeting
    @client_socket.puts "220 #{address} BlitzSMTP::MockServer"
  end
end
