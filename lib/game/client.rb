class Client
  attr_reader :name, :web_socket

  def initialize(web_socket, name)
    @web_socket = web_socket
    @name = name
  end
end
