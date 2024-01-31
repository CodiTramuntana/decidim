# frozen_string_literal: true

module Decidim
  module Forms
    # A class used to collect user answers for a questionnaire
    class QuestionnaireUserAnswers < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # questionnaire - a Questionnaire object
      # user - a User object
      def self.for(questionnaire, user)
        new(questionnaire, user).query
      end

      # Initializes the class.
      #
      # questionnaire - a Questionnaire object
      # user          - a User object
      def initialize(questionnaire, user)
        @questionnaire = questionnaire
        @user = user
      end

      # Finds and group answers by user for each questionnaire's question.
      def query
        answers = Answer.not_separator
                        .not_title_and_description
                        .joins(:question)
                        .where(questionnaire: @questionnaire, user: @user)

        [answers.sort_by { |answer| answer.question.position }]
      end
    end
  end
end
