require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module GmailCLI
  class GmailService
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'Gmail CLI'
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY
    DEFAULT_CREDENTIALS_FILE = File.join(Dir.home, '.gmail-cli', 'credentials.json')

    def initialize(account_config = nil)
      @token_file = account_config&.fetch(:token_file)
      @credentials_file = account_config&.fetch(:credentials_file) || DEFAULT_CREDENTIALS_FILE
      
      @service = Google::Apis::GmailV1::GmailService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = authorize
    end

    def authorize
      raise Error, "No credentials.json found at #{@credentials_file}. Please download it from Google Cloud Console." unless File.exist?(@credentials_file)

      client_id = Google::Auth::ClientId.from_file(@credentials_file)
      
      # Create a temporary token store if none provided
      if @token_file.nil?
        temp_token_file = File.join(Dir.home, '.gmail-cli', 'temp_token.yaml')
        FileUtils.mkdir_p(File.dirname(temp_token_file))
        token_store = Google::Auth::Stores::FileTokenStore.new(file: temp_token_file)
      else
        FileUtils.mkdir_p(File.dirname(@token_file))
        token_store = Google::Auth::Stores::FileTokenStore.new(file: @token_file)
      end

      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'

      credentials = token_store ? authorizer.get_credentials(user_id) : nil
      
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "\nTo authenticate with Gmail, follow these steps:"
        puts "1. Open this URL in your browser:"
        puts url
        puts "\n2. Select the Gmail account you want to use"
        puts "3. Grant access to Gmail CLI"
        print "\nEnter the authorization code: "
        code = STDIN.gets.chomp

        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id,
          code: code,
          base_url: OOB_URI
        )

        if @token_file.nil?
          # Get the email and create a proper token file
          @service.authorization = credentials
          email = get_account_email
          @token_file = File.join(Dir.home, '.gmail-cli', "token_#{email}.yaml")
          
          # Move credentials to the proper token file
          FileUtils.mv(temp_token_file, @token_file)
          token_store = Google::Auth::Stores::FileTokenStore.new(file: @token_file)
          authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
          credentials = authorizer.get_credentials(user_id)
        end
      end
      
      credentials
    end

    def list_labels
      user_id = 'me'
      result = @service.list_user_labels(user_id)
      result.labels
    rescue Google::Apis::Error => e
      raise Error, "Failed to fetch labels: #{e.message}"
    end

    def list_unread_messages(max_results = 10)
      user_id = 'me'
      query = 'is:unread'
      
      response = @service.list_user_messages(user_id, q: query, max_results: max_results)
      return [] if response.messages.nil?

      response.messages.map do |message|
        msg = @service.get_user_message(user_id, message.id)
        {
          id: message.id,
          thread_id: msg.thread_id,
          subject: msg.payload.headers.find { |h| h.name == 'Subject' }&.value || '(no subject)',
          from: msg.payload.headers.find { |h| h.name == 'From' }&.value || '(unknown sender)',
          browser_link: "https://mail.google.com/mail/u/0/#inbox/#{msg.thread_id}",
          account: get_account_email
        }
      end
    rescue Google::Apis::Error => e
      raise Error, "Failed to fetch messages: #{e.message}"
    end

    def get_account_email
      user_id = 'me'
      profile = @service.get_user_profile(user_id)
      profile.email_address
    rescue Google::Apis::Error => e
      raise Error, "Failed to get email address: #{e.message}"
    end
  end
end
