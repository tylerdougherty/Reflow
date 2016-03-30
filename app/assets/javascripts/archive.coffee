@post_download = (caller, archiveID) -> # Download button click action
  $(caller).addClass('disabled')
  $.post(
    '/archive/download',
    {id:archiveID},
    (data) -> # Callback function
      if data.success
        toastr.info(data.message)
      else
        toastr.error(data.message)
  )