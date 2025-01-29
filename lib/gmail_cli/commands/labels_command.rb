module GmailCLI
  module Commands
    class LabelsCommand < Thor::Group
      include Thor::Actions
      
      class_option :account, aliases: "-a", type: :string,
                   desc: "Specific account to check (default: first account)"

      def self.desc
        "List all Gmail labels"
      end

      def list_labels
        account_manager = AccountManager.new
        
        # Get the account configuration
        account_name = options[:account]
        configs = if account_name
          raise Error, "Account '#{account_name}' not found" unless account_manager.get_account(account_name)
          [[account_name, account_manager.get_account(account_name)]]
        else
          account_manager.each_account.to_a
        end

        if configs.empty?
          puts "No accounts configured. Use 'gmail-cli account add' to add an account."
          return
        end

        configs.each do |name, config|
          service = GmailService.new(config)
          labels = service.list_labels
          
          puts "\nLabels for account '#{name}':"
          puts "-" * (20 + name.length)
          
          if labels.empty?
            puts "No labels found."
          else
            labels.each { |label| puts "- #{label.name}" }
          end
        end
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
