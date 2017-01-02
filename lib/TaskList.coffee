{SelectListView, View} = require 'atom-space-pen-views'
#{,View} = require 'atom'
class TaskList extends SelectListView
    constructor:(@currentTask,@tasks,@taskSelected)->
        super()
    modal:null
    command:null
    initialize: () ->
      super()
      @storeFocusedElement()
      @modal = atom.workspace.addModalPanel(item:@element)
      @on 'blur', => @close()
      @command = atom.commands.add @element , 'core:cancel':=>@close()
      @setItems(@tasks)
      @focusFilterEditor()

    focusActivePane: () ->
        active =  atom.workspace.getActivePane()
        if active then active.activate()

    close: ->
      @command.dispose()
      @modal.destroy()
      @focusActivePane()



    getFilterKey:->"name"
    viewForItem:(item)->

        if item==@currentTask
          "<li class='status-modified'>#{item.name}</li>"
        else
          "<li>#{item.name}</li>"
    confirmed:(item)->
        @close()
        @taskSelected(item)
        @focusActivePane()


module.exports =
  TaskList:TaskList
