require 'spec_helper'

describe BlitzSMTP::Client do

  before do
    @server = BlitzSMTP::MockServer.new
    @client = BlitzSMTP::Client.new(@server.address, @server.port)
  end

  after do
    @server.shutdown!
  end

  it "should initialize disconnected" do
    @client.should_not be_connected
  end

  it "connects to the mock server" do
    @client.connect
    @client.should be_connected
    @server.should be_connected_to_client
  end

  it "disconnects from the mock server" do
    @client.connect
    @client.disconnect
    @client.should_not be_connected
    @server.should_not be_connected_to_client
  end

  it "can't disconnect unless connected" do
    lambda { @client.disconnect }.should \
      raise_error(BlitzSMTP::Client::NotConnected)
  end

  it "can't connect if connected" do
    @client.connect
    lambda { @client.connect }.should \
      raise_error(BlitzSMTP::Client::AlreadyConnected)
  end

  it "can connect again after disconnecting" do
    @client.connect
    @client.disconnect
    @client.connect
    @client.should be_connected
    @server.should be_connected_to_client
  end

end
