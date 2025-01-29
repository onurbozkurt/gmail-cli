module GmailCLI
  module Commands
    class UnreadCommand < Thor::Group
      include Thor::Actions
      
      class_option :count, aliases: "-n", type: :numeric, default: 10,
                   desc: "Number of messages to show per account (default: 10)"
      class_option :account, aliases: "-a", type: :string,
                   desc: "Specific account to check (default: all accounts)"

      def self.desc
        "List unread messages"
      end

      def list_unread
        account_manager = AccountManager.new
        all_messages = []

        if options[:account]
          # Check specific account
          config = account_manager.get_account(options[:account])
          raise Error, "Account '#{options[:account]}' not found" unless config
          
          service = GmailService.new(config)
          all_messages = service.list_unread_messages(options[:count])
        else
          # Check all accounts
          account_manager.each_account do |name, config|
            begin
              service = GmailService.new(config)
              messages = service.list_unread_messages(options[:count])
              messages.each { |msg| msg[:account] = name }
              all_messages.concat(messages)
            rescue Error => e
              puts "Warning: Failed to fetch messages from account '#{name}': #{e.message}"
            end
          end
        end

        if all_messages.empty?
          puts "No unread messages found."
        else
          puts "\nUnread Messages:"
          puts "---------------"
          all_messages.each do |msg|
            puts "\nAccount: #{msg[:account]}"
            puts "From: #{msg[:from]}"
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
