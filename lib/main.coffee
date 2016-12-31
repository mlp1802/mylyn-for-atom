{Disposable, CompositeDisposable} = require 'event-kit'
{renameCurrentTask,setView,newTask,onDidChangeActivePaneItem,allowedFiles,getMylyn,setMylyn,toggleFilter,showTaskList} = require "./mylyn"
path = require 'path'

module.exports =
  treeView: null
  observer: null


  activateMylyn:(state) ->
    mylyn = state.mylyn
    if mylyn then setMylyn(mylyn)
    console.log(mylyn)

    @observer =  atom.workspace.onDidChangeActivePaneItem((e)=>
        onDidChangeActivePaneItem(e)
        @createView().updateRoots()
        @createView().revealActiveFile()
        )

  activate: (@state) ->
    @activateMylyn(@state)

    @disposables = new CompositeDisposable
    @state.attached ?= true if @shouldAttach()
    @createView() if @state.attached
    setView(@createView())
    @disposables.add atom.commands.add('atom-workspace', {
      'list:toogle-filter': =>
        toggleFilter()
        @createView().updateRoots()

      'list:tasklist': =>
          showTaskList(@createView())
      'list:new-task': =>newTask()


      'list:update-view': => @createView().updateRoots()
      'list:rename-current-task': => renameCurrentTask()
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
          r = @treeView.serialize()
          r.mylyn = getMylyn()
          r
       else
          @state.mylyn = getMylyn()
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
