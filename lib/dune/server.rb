require 'celluloid/io'
require 'openssl'
require 'dune/stream'
require 'dune/router'
require 'dune/storage'
require 'dune/configuration'
require 'dune/logger'

module Dune
  class Server
    include Celluloid::IO

    attr_reader :router, :storage, :config, :logger

    def initialize
      @config = Configuration.new

      host = config.client.host
      port = config.client.port

      @router = Router.new
      @storage = config.storage.driver.new(config.storage.connection_params)

      @server = TCPServer.new(host, port)

      @logger = Dune::Logger.new(STDOUT)
      logger.level = Dune::Logger::DEBUG

      logger.info("Accepting client connections on #{host}:#{port}")


      #async.run
      run
    end

    def run
      #loop { async.handle_connection @server.accept }
      loop { handle_connection @server.accept }
    end

    private

    def handle_connection(socket)
      logger.info "New connection"
      stream = Dune::Stream.new(socket, self)
      @router << stream

      stream.run

      @router >> stream
    end
  end
end
