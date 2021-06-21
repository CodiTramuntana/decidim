# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      module QuestionnaireTemplates
        # This controller allows an admin to send a questionnaire form for a questionnaire_template
        class PreviewsController < Admin::ApplicationController
          include Decidim::Forms::Concerns::HasQuestionnaire

          helper_method :current_settings, :component_settings, :current_participatory_space
          # helper Decidim::Admin::ExportsHelper

          def questionnaire_for
            template
          end

          def allow_answers?
            true
          end

          def update_url
            questionnaire_preview_path(template)
            # questionnaire_path(template)
          end

          def form_path
            edit_questionnaire_template_path(template)
          end

          def after_answer_path
            questionnaire_preview_path(template)
          end

          # def public_url
          #   nil
          # end

          # def edit_questionnaire_title
          #   t(:title, scope: "decidim.templates.admin.questionnaire_templates.form", questionnaire_for: translated_attribute(template.name))
          # end

          private

          def template
            @template ||= Template.find(params[:id])
          end

          def current_settings
            @current_settings||= OpenStruct.new(announcement: nil)
          end
          alias :component_settings :current_settings

          def current_participatory_space
            @current_participatory_space||= begin
              Struct.new("TmpStruct", :ignoreme) do
                def can_participate?(current_user)
                  current_user.admin?
                end
              end
              Struct::TmpStruct.new(:whatever)
            end
          end
        end
      end
    end
  end
end
