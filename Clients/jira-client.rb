module JiraClient

  @username = "jordanfarn23"
  @password = "FuckYou!23@@"

  @options = {
              :username => @username,
              :password => @password,
              :site     => 'https://hbatelier.atlassian.net',
              :context_path => '/rest/api/2',
              :auth_type => :basic,
              :read_timeout => 120
            }
  @headers = {
    "Content-Type" => 'application/json'
  }

  @client = JIRA::Client.new(@options)


  def create_jira data
    @project = data[:project]
    @project ||= ''
    unless @project.empty?
      body = build_body data
      @client = @client.request_client
      response = @client.make_request("POST", "#{@options[:site]}#{@options[:context_path]}/issue/", body, @headers)
    else
      return {error: "needs project"}
    end
  end

  def build_body data
    hash = {fields: {
        project: {
          key: "#{data[:project]}"
        },
        summary: "#{data[:summary]}",
        issuetype: {
          name: "#{data[:type]}"
        }
      }
    }
    if data[:priority]
        hash[:fields][:priority] = {}
        hash[:fields][:priority][:name] = data[:priority]
    elsif data[:assignee]
      hash[:fields][:assignee] = {}
      hash[:fields][:assignee][:name] = data[:assignee]
    elsif data[:description]
      hash[:fields][:description] = data[:description]
    end
    json = hash.to_json
  end

end
