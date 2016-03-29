@post_download = (id) ->
  $.post('/archive/download', {id:id},
    (data) ->
      output = data.result
  )