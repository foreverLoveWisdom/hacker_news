# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  console.log "Inside of home coffeescript"

  theUrl = document.getElementById('article_url_0').innerText

  console.log theUrl

  $.ajax
    url: theUrl
    success: (result) ->
      console.log 'Success...${result}'
      return

    error: (result) ->
      console.log 'Success...${result}'
      return
