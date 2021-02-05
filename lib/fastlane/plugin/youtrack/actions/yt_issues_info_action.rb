require 'fastlane/action'
require_relative '../helper/youtrack_helper'

module Fastlane
  module Actions
    class YtIssuesInfoAction < Action
      def self.run(params)
        isssue_ids = params[:issue_ids]
        fields = params[:issue_fields]
        must_be_converted = params[:must_be_converted]
        base_url = params[:base_url]
        access_token = params[:access_token]

        if must_be_converted
          isssue_ids = isssue_ids.map { |id| id.upcase.gsub('_', '-') }
        end

        issues_info = isssue_ids.map do |issue_id|
          info = {
            url: "#{base_url}/issue/#{issue_id}"
          }
          result = Helper::YoutrackHelper.get_issue_info(issue_id, fields, base_url, access_token)
          return info unless result.success?

          begin
            response_body = JSON.parse(result.body)
            info[:title] = response_body['summary']
            info[:description] = response_body['description']
          rescue JSON::ParserError => e
            puts e
            return info
          end

          info
        end

        return issues_info
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
          FastlaneCore::ConfigItem.new(key: :issue_ids,
                                       description: 'Array of issue\'s ids',
                                       optional: false,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :must_be_converted,
                                       description: 'Sign to convert identifiers into camel-kebab case (from ios_1234 to IOS-1234)',
                                       optional: true,
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :issue_fields,
                                       description: 'Array of neccessary fields of issue',
                                       optional: true,
                                       default_value: ['summary', 'description'],
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :base_url,
                                       env_name: 'YOUTRACK_BASE_URL',
                                       description: 'Base YouTrack URL',
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :access_token,
                                       env_name: 'YOUTRACK_API_TOKEN',
                                       description: 'Access token for YouTrack API',
                                       optional: false,
                                       type: String)
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

      def self.return_type
        :array
      end
    end
  end
end
