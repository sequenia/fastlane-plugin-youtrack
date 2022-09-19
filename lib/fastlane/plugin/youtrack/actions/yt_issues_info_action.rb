require 'fastlane/action'
require_relative '../helper/youtrack_helper'

module Fastlane
  module Actions
    module SharedValues
      YOUTRACK_RELEASED_ISSUES ||= :YOUTRACK_RELEASED_ISSUES # originally defined in IncrementBuildNumberAction
    end
    class YtIssuesInfoAction < Action
      def self.run(params)
        issue_ids = params[:issue_ids]
        fields = params[:issue_fields]
        custom_fields_names = params[:issue_custom_fields_names]
        base_url = params[:base_url]
        access_token = params[:access_token]

        issues_info = issue_ids.map do |issue_id|
          info = {
            id: issue_id,
            url: "#{base_url}/issue/#{issue_id}"
          }

          issue_info_result = Helper::YoutrackHelper.get_issue_info(
            issue_id,
            fields,
            base_url,
            access_token
          )
          return info unless issue_info_result.success?

          begin
            issue_info_response_body = JSON.parse(issue_info_result.body)
            fields.each { |field| info[field.to_sym] = issue_info_response_body[field] }
          rescue JSON::ParserError => e
            puts e
            return info
          end

          issue_custom_fields_result = Helper::YoutrackHelper.get_issue_custom_fields(
            issue_id,
            base_url,
            access_token
          )

          return info unless issue_custom_fields_result.success?

          begin
            issue_custom_fields_response_body = JSON.parse(issue_custom_fields_result.body)
            custom_fields_names.each do |field_name|
              custom_field = issue_custom_fields_response_body.find { |field| 
                field['name'] == field_name
              }

              next if custom_field.nil?

              info[field_name.to_sym] = {
                type: custom_field['$type'],
                name: custom_field['name'],
                value: custom_field['value']['name']
              }
            end
          rescue JSON::ParserError => e
            puts e
            return info
          end

          info
        end

        Actions.lane_context[SharedValues::YOUTRACK_RELEASED_ISSUES] = issues_info

        issues_info
      rescue => ex
        UI.error(ex)
        UI.error('Failed')
      end

      def self.description
        'Get info about YouTrack\'s issues (summary, description etc.)'
      end

      def self.details
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :issue_ids,
            description: 'Array of issue\'s ids',
            optional: false,
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :issue_fields,
            description: 'Array of neccessary fields of issue',
            optional: true,
            default_value: ['summary', 'description'],
            type: Array
          ),
          FastlaneCore::ConfigItem.new(
            key: :issue_custom_fields_names,
            description: 'Array of names of neccessary custom fields of issue',
            optional: true,
            default_value: ['Kanban State', 'Stage'],
            type: Array
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
        'Hashes with issues info'
      end

      def self.authors
        ['Semen Kologrivov']
      end

      def self.is_supported?(_)
        true
      end

      def self.example_code
        [
          'yt_issues_info(issue_ids: ["ios_1234", "ios_5678", "ios_4321"])'
        ]
      end

      def self.output
        [
          ['YOUTRACK_RELEASED_ISSUES', 'Array of released issues']
        ]
      end

      def self.return_type
        :array
      end
    end
  end
end