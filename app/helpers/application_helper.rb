module ApplicationHelper

  # Return the javascript needed to start the backbone app and populate datas
  def init_backbone(mailboxes)
    javascript_tag "$.ready(Webmail.init({mailboxes: #{mailboxes.to_json}}))"
  end
end
