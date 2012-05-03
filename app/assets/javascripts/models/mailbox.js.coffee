Webmail.Models.Mailbox = Backbone.Model.extend

  # Return a boolean
  # Test if the mailbox has the given flag
  flagged: (flag) ->
    flags = this.get 'flags'
    _.include(flags, flag)

  # Test if this mailbox have child
  # Possibilities:
  # - "HasChild"
  # - "HasNoChild"
  # - "HasChild" + "HasNoChild" => returned by Gimap, this is a BUG?, see: rfc3348 (page 3)
  # - nothing
  hasChild: ->
    if this.flagged? "Haschild"
      return true if !this.flagged? "Hasnochild"
    return false

  # Test ig the mailbox is selectable
  selectable: ->
    !this.flagged? "Noselect"
