class Client
  attr_reader :name, :web_socket
  attr_accessor :room

  def initialize(web_socket=nil, name=nil)
    @web_socket = web_socket
    @name = name
  end

  def disconnect
    puts "disconnecting #{name}"
    if @room
      @room.remove_player(self)
    end
  end
end
