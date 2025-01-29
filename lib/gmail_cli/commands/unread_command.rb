module GmailCLI
  module Commands
    class UnreadCommand < Thor::Group
      include Thor::Actions
      
      class_option :count, aliases: "-n", type: :numeric, default: 10,
                   desc: "Number of messages to show (default: 10)"

      def self.desc
        "List unread messages"
      end

      def list_unread
        service = GmailService.new
        messages = service.list_unread_messages(options[:count])
        
        if messages.empty?
          puts "No unread messages found."
        else
          puts "\nUnread Messages:"
          puts "---------------"
          messages.each do |msg|
            puts "\nFrom: #{msg[:from]}"
            puts "Subject: #{msg[:subject]}"
            puts "Link: #{msg[:browser_link]}"
          end
        end
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
