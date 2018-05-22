# frozen_string_literal: true

namespace :decidim do
  desc "Install migrations from Decidim to the app."
  task upgrade: ["railties:install:migrations"]

  desc "Deletes the data portability file inside tmp/data-portability folder."
  task delete_data_portability_files: :environment do
    puts "DELETE DATA PORTABILITY FILES: -------------- START"
    path = "tmp/data-portability/*"
    Dir.glob(Rails.root.join(path)).each do |filename|
      next unless File.mtime(filename) < Decidim.time_data_portability_files_available.days.ago
      File.delete(filename)
      puts "------"
      puts "!! deleting #{filename}"
      puts "------"
    end
    puts "DELETE DATA PORTABILITY FILES: --------------- END"
  end
end
