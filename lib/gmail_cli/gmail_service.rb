require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module GmailCLI
  class GmailService
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'Gmail CLI'
    CREDENTIALS_PATH = File.join(Dir.home, '.gmail-cli', 'credentials.json')
    TOKEN_PATH = File.join(Dir.home, '.gmail-cli', 'token.yaml')
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY

    def initialize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
      @service = Google::Apis::GmailV1::GmailService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = authorize
    end

    def authorize
      client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'

      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "Open the following URL in your browser and authorize the application:"
        puts url
        print "Enter the authorization code here: "
        code = gets.chomp
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id,
          code: code,
          base_url: OOB_URI
        )
      end
      credentials
    end

    def list_labels
      user_id = 'me'
      result = @service.list_user_labels(user_id)
      result.labels
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
          browser_link: "https://mail.google.com/mail/u/0/#inbox/#{msg.thread_id}"
        }
      end
    rescue Google::Apis::Error => e
      raise Error, "Failed to fetch messages: #{e.message}"
    end
  end
end
