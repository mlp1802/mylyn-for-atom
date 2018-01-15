{SelectListView, View} = require 'atom-space-pen-views'
_ = require "lodash"
#{,View} = require 'atom'
getSortName = (item,currentTask)=>
  if not  currentTask then return item.name
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
        if @currentTask!=null && item.name==@currentTask.name
          "<li class='status-modified'>#{name}</li>"
        else
          "<li>#{name}</li>"
    confirmed:(item)->
        @close()
        @taskSelected(item)
        @focusActivePane()


class FileList extends SelectListView
    constructor:(@args,@fileSelected)->
        super()
    modal:null
    command:null
    initialize: () ->
      super()
      @storeFocusedElement()
      @modal = atom.workspace.addModalPanel(item:@element)
      @on 'blur', => @close()
      @command = atom.commands.add @element , 'core:cancel':=>@close()
      sorted  = _.sortBy @args.files,"points"
      lastSelected = @args.lastSelectedFile
      f_ = (x)=>
        x.path!=lastSelected.path
      if lastSelected
        sorted = (_.filter sorted,f_).reverse()
        sorted = _.concat lastSelected,sorted
      @setItems sorted
      @focusFilterEditor()

    focusActivePane: () ->
        active =  atom.workspace.getActivePane()
        if active then active.activate()

    close: ->
      @command.dispose()
      @modal.destroy()
      @focusActivePane()

    getFilterKey:->"path"
    viewForItem:(item)->
        name  = _.last(item.path.split("/"))
        if @args.currentFilePath==item.path
          "<li class='status-modified'>#{name}</li>"
        else
          "<li>#{name}</li>"
    confirmed:(item)->
        @close()
        @fileSelected(item)
        @focusActivePane()
module.exports =
  TaskList:TaskList
  FileList:FileList
