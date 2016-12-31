{SelectListView, View} = require 'atom-space-pen-views'
#{,View} = require 'atom'
class TaskList extends SelectListView
    constructor:(@currentTask,@tasks,@taskSelected)->
        super()
    modal:null
    command:null
    initialize: () ->
      super()
      @modal = atom.workspace.addModalPanel(item:@element)
      @on 'blur', => @close()
      @command = atom.commands.add @element , 'core:cancel':=>@close()
      @setItems(@tasks)
      @focusFilterEditor()
    close: ->
      @command.dispose()
      @modal.destroy()
    getFilterKey:->"name"  
    viewForItem:(item)->

        if item==@currentTask
          "<li class='status-modified'>#{item.name}</li>"
        else
          "<li>#{item.name}</li>"
    confirmed:(item)->
        @close()
        @taskSelected(item)


module.exports =
  TaskList:TaskList
