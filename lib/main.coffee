{Disposable, CompositeDisposable} = require 'event-kit'

path = require 'path'
{TaskList} = require("./TaskList")
{SelectListView, View} = require 'atom-space-pen-views'
#{,View} = require 'atom'
FileIcons = require './file-icons'

toRelPath = (path)->atom.project.relativizePath(path)[1]
createTask = (name)->
    name:name
    files:[]
currentTask = createTask("Task1")
task2 = createTask("Task2")
task3 = createTask("Task3")
task4 = createTask("Task4")


tasks = [currentTask,task2,task3,task4]
showTaskList =(view)->tasklist = new TaskList currentTask, tasks,(task)->
    console.log("task selected ")
    currentTask = task
    view.updateRoots()
filterOn = false

getFiles = ->currentTask.files
isDirAllowed = (dir)->
    if filterOn
      dir = toRelPath(dir)
      getFiles().find((file)->file.startsWith(dir))!=undefined
    else
      true

isFileAllowed = (file)->
  if filterOn
    toRelPath(file) in getFiles()
  else
    true





addFile =(file)->
      getFiles().push(path)


onDidChangeActivePaneItem = (e)->
      workspaceView = atom.views.getView(atom.workspace)
      activeEditor = atom.workspace.getActiveTextEditor()
      if activeEditor
        activePane = atom.workspace.getActivePane()
        path =  toRelPath(activeEditor.getBuffer().getPath())
        addFile(path)
        #atom.commands.dispatch(workspaceView, 'tree-view:reveal-active-file')
        activePane.activate()

allowedFiles = {
    isDirAllowed:isDirAllowed
    isFileAllowed:isFileAllowed

  }
module.exports =
  treeView: null
  observer: null


  activateMylyn:() ->
    @observer =  atom.workspace.onDidChangeActivePaneItem((e)=>
        onDidChangeActivePaneItem(e)
        @createView().updateRoots()
        @createView().revealActiveFile()
        )


  activate: (@state) ->
    @activateMylyn()

    @disposables = new CompositeDisposable
    @state.attached ?= true if @shouldAttach()

    @createView() if @state.attached

    @disposables.add atom.commands.add('atom-workspace', {
      'tree-view:show': => @createView().show()
      'tree-view:toogle-filter': =>
        filterOn = !filterOn
        @createView().updateRoots()

      'tree-view:tasklist': =>
          showTaskList(@createView())

      'tree-view:show': => @createView().show()
      'tree-view:toggle': => @createView().toggle()
      'tree-view:toggle-focus': => @createView().toggleFocus()
      'tree-view:reveal-active-file': =>  @createView().revealActiveFile()
      'tree-view:toggle-side': => @createView().toggleSide()
      'tree-view:add-file': => @createView().add(true)
      'tree-view:add-folder': => @createView().add(false)
      'tree-view:duplicate': => @createView().copySelectedEntry()
      'tree-view:remove': => @createView().removeSelectedEntries()
      'tree-view:rename': => @createView().moveSelectedEntry()
      'tree-view:show-current-file-in-file-manager': => @createView().showCurrentFileInFileManager()

    })

  deactivate: ->
    @disposables.dispose()
    @fileIconsDisposable?.dispose()
    @treeView?.deactivate()
    @treeView = null

  consumeFileIcons: (service) ->
    FileIcons.setService(service)
    @treeView?.updateRoots()
    new Disposable =>
      FileIcons.resetService()
      @treeView?.updateRoots()

  serialize: ->
    if @treeView?
      @treeView.serialize()
    else
      @state

  createView: ->
    unless @treeView?
      TreeView = require './tree-view'

          #(path)-> path.includes("main")

          #["main.coffee","helpers.coffee"]
      @treeView = new TreeView(@state,allowedFiles)
    @treeView

  shouldAttach: ->
    projectPath = atom.project.getPaths()[0] ? ''
    if atom.workspace.getActivePaneItem()
      false
    else if path.basename(projectPath) is '.git'
      # Only attach when the project path matches the path to open signifying
      # the .git folder was opened explicitly and not by using Atom as the Git
      # editor.
      projectPath is atom.getLoadSettings().pathToOpen
    else
      true
