{Disposable, CompositeDisposable} = require 'event-kit'
path = require 'path'

FileIcons = require './file-icons'
toRelPath = (path)->atom.project.relativizePath(path)[1]
mylynFiles = []
isDirAllowed = (dir)->
    console.log("dir1 = "+dir)
    dir = toRelPath(dir)
    console.log("dir = "+dir)

      #console.log("dir2 = "+dir)
    mylynFiles.find((file)->file.startsWith(dir))!=undefined

isFileAllowed = (file)->toRelPath(file) in mylynFiles





addFile =(file)->
      mylynFiles.push(path)
      console.log("ADDING FILE "+path)
      console.log("mylynFiles "+mylynFiles)

onDidChangeActivePaneItem = (e)->
      workspaceView = atom.views.getView(atom.workspace)
      activeEditor = atom.workspace.getActiveTextEditor()
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

      'mylyn:show': => @createView().show()
      'mylyn:toggle': => @createView().toggle()
      'mylyn:toggle-focus': => @createView().toggleFocus()
      'mylyn:reveal-active-file': => @createView().revealActiveFile()
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
