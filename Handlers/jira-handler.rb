require './Parsers/jira-parser.rb'
require './Clients/jira-client.rb'

include JiraParser
include JiraClient

module JiraHandler
  def handle_jira_command data
    jira_options = JiraParser.parse_slack_response_for_jira data[:slack_data]
    case jira_options[:request_type]
    when "create"
      response = JiraClient.create_jira jira_options
      built_response = build_response response
      return built_response
    when "update"

    when "delete"

    when "comment"

    else
      puts 'error error error error error error error error error error '
    end
  end

  def build_response response
    b = JSON.parse(response.read_body)
    hash = {}
    a = JSON.parse(response.read_body)
    url = a["self"]
    hash[:url] = url
    hash[:uri] = "https://hbatelier.atlassian.net/issues/" + b["key"]
    return hash
  end

end
