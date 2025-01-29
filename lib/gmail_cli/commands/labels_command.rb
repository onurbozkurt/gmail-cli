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
        account = account_manager.get_account(account_name)
        
        if account.nil?
          puts "No accounts configured. Use 'gmail-cli account add' to add an account."
          return
        end
        
        service = GmailService.new(account)
        labels = service.list_labels
        
        puts "\nLabels for account '#{account_name || 'default'}':"
        puts "-" * (20 + (account_name || 'default').length)
        
        if labels.empty?
          puts "No labels found."
        else
          labels.each { |label| puts "- #{label.name}" }
        end
      rescue Error => e
        puts "Error: #{e.message}"
      end
    end
  end
end
