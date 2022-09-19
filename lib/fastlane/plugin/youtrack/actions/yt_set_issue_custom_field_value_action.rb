require 'fastlane/action'
require_relative '../helper/youtrack_helper'

module Fastlane
  module Actions
    class YtSetIssueCustomFieldValueAction < Action
      def self.run(params)
        issue_id = params[:issue_id]
        field = params[:field]
        field_value = params[:field_value]
        base_url = params[:base_url]
        access_token = params[:access_token]

        result = Helper::YoutrackHelper.set_custom_field_value(
          issue_id,
          field,
          field_value,
          base_url,
          access_token
        )
        return {} unless result.success?

        begin
          response_body = JSON.parse(result.body)
        rescue JSON::ParserError => e
          puts e
        end

        response_body
      rescue => ex
        UI.error(ex)
        UI.error('Failed')
      end

      def self.description
        'Set value for passed custom field name'
      end

      def self.details
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :issue_id,
            description: 'Identifier of issue',
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :field,
            description: 'Custom field info',
            optional: false,
            type: Hash
          ),
          FastlaneCore::ConfigItem.new(
            key: :field_value,
            description: 'Value of custom field',
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :base_url,
            env_name: 'YOUTRACK_BASE_URL',
            description: 'Base YouTrack URL',
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :access_token,
            env_name: 'YOUTRACK_API_TOKEN',
            description: 'Access token for YouTrack API',
            optional: false,
            type: String
          )
        ]
      end

      def self.return_value
        'Nothing'
      end

      def self.authors
        ['Semen Kologrivov']
      end

      def self.is_supported?(_)
        true
      end

      def self.example_code
        [
          'yt_set_issue_custom_field_value(issue_id: "ios_1234", field_name: "Foo", field_value: "Bar")'
        ]
      end

      def self.output
        [
          []
        ]
      end

      def self.return_type
        :array
      end
    end
  end
end
