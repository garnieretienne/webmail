Webmail.Models.Message = Backbone.Model.extend
  
  # Test if the message has the given flag
  # Return a boolean
  flagged: (flag) ->
    flags = this.get 'flags'
    _.include(flags, flag)

  # Return the from_name if exist or 
  # return the first part of the email address as name
  fromName: ->
    if this.get('from_name') != null
      this.get 'from_name'
    else
      this.get('from_address').split('@')[0]

  # Return the internaldate in short format
  # 2012-05-08T12:19:33Z => 08 Mai 2012
  shortInternalDate: ->
    monthNames = [ 
      "January"
      "February"
      "March"
      "April"
      "May"
      "June"
      "July"
      "August"
      "September"
      "October"
      "November"
      "December" 
    ]
    date = new Date this.get('internal_date')
    currentDate = new Date()
    short = date.getDate()+" "+monthNames[date.getMonth()]
    short += " "+date.getFullYear() if currentDate.getFullYear() != date.getFullYear()
    return short

  # Display the message
  display: ->
    Backbone.history.navigate("mailboxes/#{this.get("mailbox_id")}/messages/#{this.get("id")}", {trigger: true});