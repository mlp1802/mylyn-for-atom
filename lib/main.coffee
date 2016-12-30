{Disposable, CompositeDisposable} = require 'event-kit'

path = require 'path'
{TaskList} = require("./TaskList")
{SelectListView, View} = require 'atom-space-pen-views'
#{,View} = require 'atom'
FileIcons = require './file-icons'

toRelPath = (path)->atom.project.relativizePath(path)[1]
currentTask =
    name:"Task1"
    files:[]
task2 =
    name:"Task2"
    files:[]

tasks = [currentTask,task2]
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
        #atom.commands.dispatch(workspaceView, 'mylyn:reveal-active-file')
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
      'mylyn:show': => @createView().show()
      'mylyn:toogle-filter': =>
        filterOn = !filterOn
        @createView().updateRoots()

      'mylyn:tasklist': =>
          showTaskList(@createView())

      'mylyn:show': => @createView().show()
      'mylyn:toggle': => @createView().toggle()
      'mylyn:toggle-focus': => @createView().toggleFocus()
      'mylyn:reveal-active-file': =>  @createView().revealActiveFile()
      'mylyn:toggle-side': => @createView().toggleSide()
      'mylyn:add-file': => @createView().add(true)
      'mylyn:add-folder': => @createView().add(false)
      'mylyn:duplicate': => @createView().copySelectedEntry()
      'mylyn:remove': => @createView().removeSelectedEntries()
      'mylyn:rename': => @createView().moveSelectedEntry()
      'mylyn:show-current-file-in-file-manager': => @createView().showCurrentFileInFileManager()

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
