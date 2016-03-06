module JiraParser

  def parse_slack_response_for_jira slack_data
    typed_request = get_type slack_data.text
    case typed_request[:type]
    when '$create'
      create_jira_obj typed_request[:text]
    when '$update'
      update_jira_obj typed_request[:text]
    when '$delete'
      delete_jira_obj typed_request[:text]
    else
      return {error: "Parsing error, type not supported"}
    end
  end

  def get_type text
    a = text.split(" ")
    a.shift
    type = a.shift
    text = a.join(" ")
    hash = {type: type, text: text}
  end

  def create_jira_obj string
    puts 'create'
    options = parse_options string, 'create'
  end

  def update_jira_obj string
    puts 'update'
    options = parse_options string, 'update'
  end

  def delete_jira_obj string
    puts 'delete'
    options = parse_options string, 'delete'
  end

  def parse_options string, request_type
    hash = {components: [], errors: [], request_type: request_type}
    a = string.split /(\B--\S)/
    a.shift
    a.each_with_index do |s, i|
      case s
      when "--p"
        proj = a[i + 1]
        proj = format_param proj
        hash[:project] = proj
      when "--t"
        type = a[i + 1]
        type = format_param type
        hash[:type] = type
      when "--s"
        sum = a[i + 1]
        sum = format_param sum
        hash[:summary] = sum
      when "--d"
        desc = a[i + 1]
        desc = format_param desc
        hash[:description] = desc
      when "--a"
        assign = a[i + 1]
        assign = format_param assign
        hash[:assignee] = assign  
      when "--c"
        comp = a[i + 1]
        comps = comp.gsub(/[^[:alnum:]]+/, ',')
        comps = comps.split ","
        comps.shift
        comps.each_with_index do |c, i|
          hash[:components] << c
        end
      else
        hash[:errors] << "#{s}"
      end
    end
    hash
  end

  def format_param string
    string = string.gsub(/[^[:alnum:]]+/, ' ')
    string = string.split " "
    string = string.join " "
  end

end
