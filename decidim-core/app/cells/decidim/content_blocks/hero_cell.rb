# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroCell < Decidim::ViewModel
      include Decidim::CtaButtonHelper
      include Decidim::SanitizeHelper
      include Decidim::ParticipatoryProcesses::Engine.routes.url_helpers

      delegate :current_organization, to: :controller

      def translated_welcome_text
        translated_attribute(model.settings.welcome_text)
      end

      def background_image
        model.images_container.background_image.big.url
      end
    end
  end
end
