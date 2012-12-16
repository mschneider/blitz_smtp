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
      respond 220, self.class.to_s
    end

    def send_command_unknown(command)
      respond 554, "received unknown command: #{command}"
    end

    def respond(*args)
      response = Response.create(*args)
      response.write_to(@client_socket)
    end

    def mock_smtp
      send_greeting
      catch(:disconnect) do
        loop do
          command = Command.read_from(@client_socket)
          send("received_#{command.name.downcase}", command)
        end
      end
      disconnect_client
    end

    def received_ehlo(command)
      return send_command_unknown(command) unless esmtp
      continued_messages = [address] + features[0..-2]
      continued_messages.each { |m| respond 250, m, true }
      respond 250, features.last
    end

    def received_quit(_)
      respond 221, "bye"
      throw :disconnect
    end

    def method_missing(method, command, *_)
      puts "could not identify #{command} [##{method}]"
      send_command_unknown(command)
    end
  end
end
