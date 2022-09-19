require 'fastlane_core/ui/ui'
require 'faraday'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class YoutrackHelper
      # class methods that you define here become available in your action
      # as `Helper::YoutrackHelper.your_method`
      #
      def self.get_issue_info(issue_id, fields, url, token)
        Faraday.get("#{url}/api/issues/#{issue_id}") do |req|
          req.params['fields'] = fields.join(',')

          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['Cache-Control'] = 'no-cache'
          req.headers['Authorization'] = "Bearer #{token}"
        end
      end

      def self.comment_issue(issue_id, comment, url, token)
        Faraday.post("#{url}/api/issues/#{issue_id}/comments") do |req|
          body = {
            text: comment
          }
          req.body = JSON.generate(body)

          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['Cache-Control'] = 'no-cache'
          req.headers['Authorization'] = "Bearer #{token}"
        end
      end
    end
  end
end
