{SelectListView, View} = require 'atom-space-pen-views'
#{,View} = require 'atom'
_ = require("underscore")
getSortName = (item,currentTask)=>

  if item.name==currentTask.name
      "A:"+item.name
  else
      "Z:"+item.name

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
      sorted = _.sortBy @tasks,(t)=>getSortName(t,@currentTask)
      @setItems sorted
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
        name  = item.name
        if item.name==@currentTask.name
          "<li class='status-modified'>#{name}</li>"
        else
          "<li>#{name}</li>"
    confirmed:(item)->
        @close()
        @taskSelected(item)
        @focusActivePane()


module.exports =
  TaskList:TaskList
