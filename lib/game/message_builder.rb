require 'json'

module TTT
  module Game
    module MessageBuilder
      def build_message(command, options={})
        cmd = { command: command.to_sym }.merge(options)
        data = JSON.generate(cmd)
      end
    end
  end
end
