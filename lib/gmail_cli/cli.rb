require 'thor'
require 'gmail_cli/gmail_service'
require 'gmail_cli/account_manager'
require 'gmail_cli/commands/labels_command'
require 'gmail_cli/commands/unread_command'
require 'gmail_cli/commands/version_command'
require 'gmail_cli/commands/account_command'

module GmailCLI
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "account SUBCOMMAND", "Manage Gmail accounts"
    subcommand "account", Commands::AccountCommand

    desc "labels", "List all Gmail labels"
    method_option :account, aliases: "-a", type: :string,
                 desc: "Specific account to check (default: first account)"
    def labels
      account_manager = AccountManager.new
      if account_manager.get_account(options[:account])
        Commands::LabelsCommand.new(options).list_labels
      else
        puts "No accounts configured. Use 'gmail-cli account add' to add an account."
      end
    end

    desc "unread", "List unread messages"
    method_option :count, aliases: "-n", type: :numeric, default: 10,
                 desc: "Number of messages to show (default: 10)"
    method_option :account, aliases: "-a", type: :string,
                 desc: "Specific account to check (default: all accounts)"
    def unread
      Commands::UnreadCommand.new(options).list_unread
    end

    desc "version", "Show version"
    def version
      Commands::VersionCommand.new.show_version
    end
  end
end
