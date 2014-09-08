require 'spec_helper'
require 'json'
require 'aws-sdk-core'

describe SqsBunny do
  describe :run do
    before :each do
      @c = {'something'=>'here'}
      @b = double('SqsBunny')
      allow(@b).to receive(:logger=)
      @path = 'some_path'
    end
    it "should load config and pass to initialize" do
      allow(File).to receive(:exists?).with(@path).and_return true
      expect(IO).to receive(:read).with(@path).and_return @c.to_json
      expect(SqsBunny).to receive(:new).with(@c).and_return(@b)
      expect(@b).to receive(:go)
      SqsBunny.run @path
    end
    it "should raise error if setup file doesn't exist" do
      expect(File).to receive(:exists?).with(@path).and_return false
      expect {SqsBunny.run(@path)}.to raise_error "Configuration file could not be found at #{@path}"
    end
  end

  describe :go do
    before :each do
      @config = {'parent_q'=>{'queue_url'=>'my_queue'},'poll_max'=>1}
    end
    def default_receive_message base
      {wait_time_seconds:10}.merge base
    end
    #poll_max config is for test purposes and hard stops the polling loop after x number of tries
    it "should try to get messages from SQS Queue in config['parent_q']" do
      client = double('client')
      expect(Aws::SQS::Client).to receive(:new).and_return client
      expect(client).to receive(:receive_message).with(default_receive_message(queue_url:'my_queue')).and_return []
      SqsBunny.new(@config).go
    end
    it "should handle no messages behavior" do
      client = double('client')
      expect(Aws::SQS::Client).to receive(:new).and_return client
      prep_resp = double('preparedResponse')
      expect(prep_resp).to_not receive(:messages)
      expect(client).to receive(:receive_message).with(default_receive_message(queue_url:'my_queue')).and_return [prep_resp]
      SqsBunny.new(@config).go
    end
    it "should pass messages to child queue" do
      @config['children'] = [{'queue_url'=>'c1'}]

      client = double('client')
      prep_resp = double('preparedResponse')
      msg = double('msg')
      m_body = 'hello'
      r_handle = 'rh'

      expect(prep_resp).to receive(:respond_to?).with(:messages).and_return true
      expect(prep_resp).to receive(:messages).and_return [msg]
      expect(Aws::SQS::Client).to receive(:new).and_return client
      expect(client).to receive(:receive_message).with(default_receive_message(queue_url:'my_queue')).and_return prep_resp
      expect(client).to receive(:delete_message).with({queue_url:'my_queue',receipt_handle:r_handle})
      expect(client).to receive(:send_message).with({queue_url:'c1',message_body:'hello'})
      allow(msg).to receive(:body).and_return m_body
      allow(msg).to receive(:receipt_handle).and_return r_handle

      SqsBunny.new(@config).go
    end
  end
end