module GmailCLI
  module Commands
    class LabelsCommand < Thor::Group
      include Thor::Actions
      
      def self.desc
        "List all Gmail labels"
      end

      def list_labels
        service = GmailService.new
        labels = service.list_labels
        
        if labels.empty?
          puts "No labels found."
        else
          puts "\nGmail Labels:"
          puts "-------------"
          labels.each { |label| puts "- #{label.name}" }
        end
      rescue Error => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
