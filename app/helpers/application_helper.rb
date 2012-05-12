module ApplicationHelper

  # Return the javascript needed to start the backbone app and populate datas
  def init_backbone(mailboxes, messages)
    javascript_tag "$.ready(Webmail.init({mailboxes: #{mailboxes.to_json}, messages: #{messages.to_json}}))"
  end
end
