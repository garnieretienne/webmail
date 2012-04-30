module ApplicationHelper
  def init_backbone
    javascript_tag "$.ready(Webmail.init())"
  end
end
