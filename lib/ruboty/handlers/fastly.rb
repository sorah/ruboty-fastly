require "ruboty-fastly/version"
require 'ruboty/handlers/base'
require 'fastly'

module Ruboty
  module Handlers
    class Fastly < Base

      env :FASTLY_API_KEY, "Fastly API key"

      VERSION = RubotyFastly::VERSION

      on(/(?:fastly|fst)\s+list(\s+services?)?/, name: 'list_services', description: 'List Fastly services')
      on(/(?:fastly|fst)\s+(?:set|add)\s+alias\s+(?<service_id>.+?)\s+(?<name>.+?)$/, name: 'set_alias', description: 'Set alias to the Fastly service')
      on(/(?:fastly|fst)\s+remove\s+alias\s+(?<service_id>.+?)\s+(?<name>.+?)$/, name: 'remove_alias', description: 'Remove alias to the Fastly service')
      on(/(?:fastly|fst)\s+(?<soft>soft\s+)?purge\s+(?<url>http.+?)$/, name: 'purge_url', description: 'Purge single URL from Fastly')
      on(/(?:fastly|fst)\s+(?<soft>soft\s+)?purge\s+key\s+(?<service_id>.+?)\s+(?<keys>.+?)$/, name: 'purge_key', description: 'Purge by keys from Fastly')
      on(/(?:fastly|fst)\s+purge\s+all\s+(?<service_id>.+?)$/, name: 'purge_all', description: 'Purge all from Fastly service')
      on(/(?:fastly|fst)\s+(?:purge\s+)?cancel$/, name: 'purge_cancel', description: 'Cancel pending purge alls from Fastly')

      def list_services(message)
        reversed_aliases = aliases.to_a.group_by(&:last).map { |sid, _|  [sid, _.map(&:first)] }.to_h

        list =  fastly.list_services.map do |service|
          "- `#{service.id}` #{service.name}#{reversed_aliases[service.id] ? " (alias: #{reversed_aliases[service.id].join(', ')})" : nil}"
        end
        message.reply list.join("\n")
      rescue => e
        message.reply e.inspect
      end

      def set_alias(message)
        aliases[message[:name]] = message[:service_id]
        message.reply "Added an alias: #{message[:name]} > `#{message[:service_id]}`"
      rescue => e
        message.reply e.inspect
      end

      def remove_alias(message)
        if aliases.delete(message[:name])
          message.reply "Removed alias #{message[:name]}"
        else
          message.reply "Alias #{message[:name]} doesn't exist"
        end
      rescue => e
        message.reply e.inspect
      end

      def purge_url(message)
        soft = !!message[:soft]
        fastly.purge(message[:url], soft)
        message.reply "#{soft ? 'Soft ' : nil}Purged `#{message[:url]}`"
      rescue => e
        message.reply e.inspect
      end

      def purge_key(message)
        soft = !!message[:soft]
        service = service_for(message[:service_id])
        keys = message[:keys].split(/\s+/)

        keys.each do |key|
          service.purge_by_key(key, soft)
          message.reply "#{soft ? 'Soft ' : nil}Purged Fastly `#{service.id}` by key: `#{key}`"
        end
      rescue => e
        message.reply e.inspect
      end

      def purge_all(message)
        service = service_for(message[:service_id])

        Thread.new(purge_cancellations) do |count|
          begin
            sleep 15
            next if count != purge_cancellations
            service.purge_all()
            message.reply "Purged all from Fastly `#{service.id}`"
          rescue => e
            message.reply e.inspect
          end
        end
        message.reply "Purging Fastly `#{service.id}` after next 15 seconds, cancel by saying: `fastly cancel`"
      rescue => e
        message.reply e.inspect
      end

      def purge_cancel(message)
        cancel_all_pending_purges
        message.reply "Cancelled the pending purge requests."
      end

      private

      def fastly
        ::Fastly.new(api_key: ENV.fetch('FASTLY_API_KEY'))
      end

      def service_for(name)
        ::Fastly::Service.new({ id: aliases[name] || name }, fastly)
      end

      def aliases
        robot.brain.data['fastly.aliases'] ||= {}
      end

      def purge_cancellations
        @purge_cancellations ||= 0
      end

      def cancel_all_pending_purges
        @purge_cancellations = purge_cancellations + 1
      end
    end
  end
end
