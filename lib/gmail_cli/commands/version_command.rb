module GmailCLI
  module Commands
    class VersionCommand < Thor::Group
      include Thor::Actions
      
      def self.desc
        "Show version"
      end

      def show_version
        puts "Gmail CLI v#{VERSION}"
      end
    end
  end
end
