jQuery ->
  # Enable loading button on login form
  $("#login-form input[type=submit]").click ->
    $("#login-form .btn").button('loading')
