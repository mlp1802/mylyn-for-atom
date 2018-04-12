module.exports = (task) ->
  # Indicates that this task will be async.
  # Call the `callback` to finish the task
  callback = @async()

  emit('some-event-from-the-task', {someString: 'yep this is it'})

  callback()
