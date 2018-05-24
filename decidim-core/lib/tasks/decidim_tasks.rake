# frozen_string_literal: true

namespace :decidim do
  desc "Install migrations from Decidim to the app."
  task upgrade: [:choose_target_plugins, :"railties:install:migrations"]

  desc "Setup environment so that only decidim migrations are installed."
  task :choose_target_plugins do
    ENV["FROM"] = %w(
      decidim
      decidim_accountability
      decidim_admin
      decidim_assemblies
      decidim_blogs
      decidim_budgets
      decidim_comments
      decidim_consultations
      decidim_debates
      decidim_initiatives
      decidim_meetings
      decidim_pages
      decidim_participatory_processes
      decidim_proposals
      decidim_sortitions
      decidim_surveys
      decidim_system
      decidim_verifications
    ).join(",")
  end
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
