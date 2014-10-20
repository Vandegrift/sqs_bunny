require 'json'
require 'aws-sdk-core'
require 'logger'

##
# Main execution class, just call +SqsBunny.run+ and pass in the path of your configuration file

class SqsBunny
  attr_accessor :logger
  ##
  # Run this method to start the job, optionally pass in a configuration hash.  Otherwise
  # the job will look for a JSON configuration at +config/setup.json+
  def self.run config_file_path, logger=nil
    raise "Configuration file could not be found at #{config_file_path}" unless File.exists? config_file_path
    s = self.new(JSON.parse(IO.read(config_file_path)))
    s.logger = logger
    s.go
  end

  def initialize config
    @config = {'wait_time_seconds'=>10}.merge config
    @poll_count = 0
  end

  def go
    while true
      @poll_count += 1
      client = Aws::SQS::Client.new
      parent_url = @config['parent_q']['queue_url']
      log.debug "Polling for messages at #{parent_url}"
      resp = client.receive_message(queue_url:parent_url,wait_time_seconds:@config['wait_time_seconds'])
      if resp.respond_to? :messages
        resp.messages.each do |x|
          log.info x.body
          send_message client, x
          client.delete_message(queue_url:parent_url,receipt_handle:x.receipt_handle)
        end
      else 
        log.debug "No messages"
      end
      break unless keep_polling?
    end
  end

  def send_message client, message
    return unless @config['children']
    @config['children'].each do |child|
      client.send_message(queue_url:child['queue_url'],message_body:message.body)
    end
  end

  # This method can be overidden to provide your own polling stop semantics
  def keep_polling?
    @config['poll_max'].nil? || @poll_count < @config['poll_max']
  end

  class NullLogger < Logger
    def initialize(*args)
    end

    def add(*args, &block)
    end
  end

  private 
    def log
      @logger ||= NullLogger.new
    end
end