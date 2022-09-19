require 'fastlane/action'
require_relative '../helper/youtrack_helper'

module Fastlane
  module Actions
    class YtCommentIssueAction < Action
      def self.run(params)
        issue_id = params[:issue_id]
        comment = params[:comment]
        base_url = params[:base_url]
        access_token = params[:access_token]

        result = Helper::YoutrackHelper.comment_issue(issue_id, comment, base_url, access_token)
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
        'Add a comment to issue by passed identifier'
      end

      def self.details
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :issue_id,
            description: 'Identifier of commented issue',
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :comment,
            description: 'Text of comment',
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
          'yt_comment_issue(issue_id: "ios_1234", comment: "Lorem ipsum")'
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
