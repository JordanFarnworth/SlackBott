require './Parsers/jira-parser.rb'
require './Clients/jira-client.rb'
require './helpers.rb'

include Helpers
include JiraParser
include JiraClient

module JiraHandler

  def handle_jira_link data
    meta_data = JiraClient.get_meta_data
    a = JSON.parse(meta_data.body)
    projects = a["projects"].map { |p| p["key"] }
    ticket = data[:slack_data].text.match /(?:\s|^)([A-Z]+-[0-9]+)(?=\s|$)/
    check = ticket[1].split "-"
    if projects.include?(check.first) && JiraClient.real_ticket?(ticket)
      uri = JiraClient.current_uri
      url = uri + '/issues/' + ticket[1]
      return {url: url, id: ticket}
    else
      return nil
    end
  end

  def handle_jira_command data
    # meta_data = JiraClient.get_meta_data
    jira_options = JiraParser.parse_slack_response_for_jira data[:slack_data]
    case jira_options[:request_type]
    when "create"
      response = JiraClient.create_jira jira_options
      built_response = build_response response
      return built_response
    when "update"

    when "comment"

    else
      puts 'error error error error error error error error error error '
    end
  end

  def build_response response
    a = JSON.parse(response.read_body)
    hash = {}
    url = a["self"] if a["self"]
    hash[:uri] = "https://hbatelier.atlassian.net/issues/" + a["key"] if url
    if a["errors"]
      hash[:errors] = a["errors"].to_s
    end
    return hash
  end

end
