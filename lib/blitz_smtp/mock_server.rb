require 'socket'

class BlitzSMTP::MockServer

  def initialize
    @server_socket = TCPServer.new(address, 0)
    @server_thread = Thread.start do
      loop {
        @client_socket = @server_socket.accept
        send_greeting
        loop {
          command = @client_socket.gets
          case command
          when /^QUIT/
            disconnect_client
            break
          end
        }
      }
    end
  end

  def address
    "localhost"
  end

  def port
    @server_socket.connect_address.ip_port
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

  def disconnect_client
    send_to_client 221, "closing transmission channel"
    @client_socket.close
    @client_socket = nil
  end

  def send_greeting
    send_to_client 220, self.class.to_s
  end

  def send_to_client nr, message
    @client_socket.puts "#{nr} #{address} #{message}"
  end
end
