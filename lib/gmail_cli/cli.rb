require 'thor'
require 'gmail_cli/gmail_service'
require 'gmail_cli/commands/labels_command'
require 'gmail_cli/commands/unread_command'
require 'gmail_cli/commands/version_command'

module GmailCLI
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "labels", "List all Gmail labels"
    def labels
      Commands::LabelsCommand.new.list_labels
    end

    desc "unread", "List unread messages"
    method_option :count, aliases: "-n", type: :numeric, default: 10,
                 desc: "Number of messages to show (default: 10)"
    def unread
      Commands::UnreadCommand.new(options).list_unread
    end

    desc "version", "Show version"
    def version
      Commands::VersionCommand.new.show_version
    end
  end
end
