module JiraClient

  yaml_jira = YAML.load_file("./settings.yml")

  @username = yaml_jira['username']
  @password = yaml_jira['password']
  @base_url = yaml_jira['url']

  @options = {
              :username => @username,
              :password => @password,
              :site     => @base_url,
              :context_path => '/rest/api/2',
              :auth_type => :basic,
              :read_timeout => 120
            }
  @headers = {
    "Content-Type" => 'application/json'
  }

  @client = JIRA::Client.new(@options)
  @client = @client.request_client

  def get_meta_data
    meta_data = @client.make_request("GET", "#{@options[:site]}#{@options[:context_path]}/issue/createmeta", {}.to_json, @headers)
  end

  def current_uri
    "#{@options[:site]}"
  end

  def real_ticket? ticket
    response = @client.make_request("GET", "#{@options[:site]}#{@options[:context_path]}/issue/#{ticket}", {}.to_json, @headers)
    if response.code == "200"
      return true
    else
      return false
    end
  end

  def create_jira data
    @project = data[:project]
    @project ||= ''
    unless @project.empty?
      body = build_body data
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
    end
    if data[:assignee]
      hash[:fields][:assignee] = {}
      hash[:fields][:assignee][:name] = data[:assignee]
    end
    if data[:description]
      hash[:fields][:description] = data[:description]
    end
    if data[:priority]
      hash[:fields][:priority] = {}
      hash[:fields][:priority][:name] = data[:priority]
    end
    json = hash.to_json
  end

end
