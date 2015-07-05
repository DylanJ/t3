require 'securerandom'

module TTT
  module Game
    class Room
      attr_reader :name, :size, :players, :state, :id

      module STATE
        WAITING = 0
        IN_PROGRESS = 1
      end

      def initialize(owner, name="", password=nil, size=3)
        @owner = owner
        @name = name
        @password = password
        @size = size
        @state = STATE::WAITING
        @players = []
        @id = generate_id()
      end

      def valid?
        return false if @owner.nil?
        return false if @name.empty?
        return false if @size != 3 # for now :)

        true
      end

      def id= id
        @id ||= id
      end

      def simple_info
        {
          name: @name,
          password: has_password?,
          size: @size,
          id: @id,
        }
      end

      def info
        simple_info.merge(players: player_info)
      end

      private

      def has_password?
        (@password || "").size > 0
      end

      def player_info
        @players.map do |p|
          {
            name: p.name,
            score: 0,
          }
        end
      end

      def generate_id
        SecureRandom.uuid # something unique
      end
    end
  end
end
