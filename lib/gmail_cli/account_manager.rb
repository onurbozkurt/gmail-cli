require 'yaml'
require 'fileutils'

module GmailCLI
  class AccountManager
    ACCOUNTS_FILE = File.join(Dir.home, '.gmail-cli', 'accounts.yaml')

    def initialize
      @config_dir = File.join(Dir.home, '.gmail-cli')
      FileUtils.mkdir_p(@config_dir)
      load_accounts
    end

    def add_account(name)
      raise Error, "Account '#{name}' already exists" if @accounts[name]

      # Get the next available index
      used_indices = @accounts.values.map { |c| c[:account_index] }.compact
      next_index = (0..used_indices.size).find { |i| !used_indices.include?(i) } || used_indices.size

      # Create a new service without any token file to trigger the OAuth flow
      service = GmailService.new

      # The service will create a token file based on the email address
      email = service.get_account_email
      token_file = File.join(@config_dir, "token_#{email}.yaml")

      @accounts[name] = {
        email: email,
        credentials_file: GmailService::DEFAULT_CREDENTIALS_FILE,
        token_file: token_file,
        account_index: next_index
      }
      save_accounts

      puts "\nAccount '#{name}' (#{email}) added successfully."
    end

    def remove_account(name)
      raise Error, "Account '#{name}' not found" unless @accounts[name]

      # Remove token file
      FileUtils.rm(@accounts[name][:token_file]) rescue nil

      @accounts.delete(name)
      save_accounts

      puts "Account '#{name}' removed successfully."
    end

    def list_accounts
      if @accounts.empty?
        puts "No accounts configured."
      else
        puts "\nConfigured accounts:"
        puts "-----------------"
        @accounts.each do |name, config|
          puts "- #{name} (#{config[:email]})"
        end
      end
    end

    def get_account(name)
      @accounts[name]
    end

    def each_account
      @accounts.each do |name, config|
        yield name, config
      end
    end

    private

    def load_accounts
      @accounts = if File.exist?(ACCOUNTS_FILE)
        YAML.load_file(ACCOUNTS_FILE) || {}
      else
        {}
      end
    end

    def save_accounts
      File.write(ACCOUNTS_FILE, @accounts.to_yaml)
    end
  end
end
