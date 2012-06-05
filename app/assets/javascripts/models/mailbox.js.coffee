Webmail.Models.Mailbox = Backbone.Model.extend

  # On mailbox initialization, add a selected attribute to false
  initialize: ->
    this.set "selected", false

  # Return a boolean
  # Test if the mailbox has the given flag
  flagged: (flag) ->
    flags = this.get 'flags'
    _.include(flags, flag)

  # Test if this mailbox have child
  # Possibilities:
  # - "HasChildren"
  # - "HasNoChildren"
  # - "HasChildren" + "HasNoChildren" => returned by Gimap, this is a BUG?, see: rfc3348 (page 3)
  # - nothing
  hasChildren: ->
    if this.flagged? "Haschildren"
      return true if !this.flagged?("Hasnochildren")
    return false

  # Test if this mailbox have parent
  # "Parent/Child" => "Parent"
  # "Alone"        => false
  hasParent: ->
    name = this.get("name")
    titles = name.split(this.get("delimiter"))
    if (titles.length > 1)
      return titles[0]
    else
      return false

  # Test if the mailbox is selectable
  selectable: ->
    !this.flagged? "Noselect"

  # Display the display name (title) of the mailbox
  title: ->
    if this.hasParent()
      return this.get("name").split(this.get("delimiter"))[1]
    else
      return this.get "name"

  # Select the mailbox
  select: ->
    # Unmark any pre-selected mailbox
    selected = this.collection.where 
      selected: true
    _.each selected, (mailbox) ->
      mailbox.set "selected", false

    # Mask this mailbox as selected
    this.set "selected", true

  # Display the message list
  display: ->
    Backbone.history.navigate("mailboxes/#{this.id}", {trigger: true});