Webmail.Collections.Mailboxes = Backbone.Collection.extend
  model: Webmail.Models.Mailbox
  url: '/api/mailboxes'

  # Sort the mailboxes per alphabetic order
  # ALWAYS puts INBOX special mailbox on the top
  comparator: (mailbox1, mailbox2) ->
    
    # Always return INBOX on top of the list
    return -1 if mailbox1.get("name") == "INBOX"
    return 1 if mailbox2.get("name") == "INBOX"

    # split each mailbox names
    chars1 = mailbox1.get("name").split("")
    chars2 = mailbox2.get("name").split("")

    # find the longer mailbox name
    length = 0
    length1 = chars1.length
    length2 = chars2.length
    if chars1.length < chars2.length
      length = length1 - 1
      longer = -1
    else 
      length = length2 - 1 
      longer = 1

    # return the alphabetical order
    for i in [0..length]
      if chars1[i].charCodeAt() > chars2[i].charCodeAt()
        return 1
        break
      else if chars1[i].charCodeAt() < chars2[i].charCodeAt()
        return -1
        break

    # If no order has been found, return the longer one
    return longer