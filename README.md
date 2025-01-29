# Gmail CLI

A command-line interface for Gmail built with Ruby and Thor.

## Installation

1. Clone this repository
2. Run `bundle install`
3. Place your Google OAuth credentials in `~/.gmail-cli/credentials.json`

## Usage

```bash
# List all available commands
./bin/gmail-cli help

# List Gmail labels
./bin/gmail-cli labels

# Show unread messages (default: 10)
./bin/gmail-cli unread

# Show specific number of unread messages
./bin/gmail-cli unread --count 5

# Show version
./bin/gmail-cli version
```

## First-time Setup

1. Create a project in Google Cloud Console
2. Enable Gmail API
3. Create OAuth 2.0 credentials
4. Download credentials and save as `~/.gmail-cli/credentials.json`
5. Run any command and follow the authorization flow

## License

MIT
