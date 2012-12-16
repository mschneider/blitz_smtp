require 'socket'

module BlitzSMTP
  class MockServer

    attr_accessor :esmtp, :features

    def initialize
      @esmtp = true
      @features = []
      @server_socket = TCPServer.new(address, 0)
      @server_thread = Thread.start do
        loop do
          @client_socket = @server_socket.accept
          mock_smtp
        end
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
      @client_socket.close
      @client_socket = nil
    end

    def send_greeting
      send_to_client 220, self.class.to_s
    end

    def send_to_client nr, message, continue=false
      separator = continue ? "-" : " "
      @client_socket.print "#{nr}#{separator}#{message}\r\n"
    end

    def mock_smtp
      send_greeting
      catch(:disconnect) do
        loop do
          command = @client_socket.gets
          send("received_#{command[0..3].downcase}", command)
        end
      end
      disconnect_client
    end

    def received_ehlo(command)
      return send_to_client(554, "received: #{command}") unless esmtp
      continued_messages = [address] + features[0..-2]
      continued_messages.each { |m| send_to_client 250, m, true }
      send_to_client 250, features.last
    end

    def received_quit(_)
      send_to_client 221, "bye"
      throw :disconnect
    end

    def method_missing(method, *args)
      puts "could not identify #{args} [##{method}]"
      send_to_client 500, "received: #{args.first}"
    end
  end
end
