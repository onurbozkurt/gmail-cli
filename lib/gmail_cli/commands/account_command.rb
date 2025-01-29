module GmailCLI
  module Commands
    class AccountCommand < Thor
      desc "add", "Add a new Gmail account"
      method_option :name, aliases: "-n", type: :string, required: true,
                   desc: "Account name"
      def add
        account_manager = AccountManager.new
        account_manager.add_account(options[:name])
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end

      desc "remove", "Remove a Gmail account"
      method_option :name, aliases: "-n", type: :string, required: true,
                   desc: "Account name to remove"
      def remove
        account_manager = AccountManager.new
        account_manager.remove_account(options[:name])
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end

      desc "list", "List configured Gmail accounts"
      def list
        account_manager = AccountManager.new
        account_manager.list_accounts
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
