{TaskList} = require("./TaskList")

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
      getFiles().push(file)


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

toggleFilter = ->
  filterOn = !filterOn

module.exports =
    onDidChangeActivePaneItem:onDidChangeActivePaneItem
    allowedFiles:allowedFiles
    toggleFilter:toggleFilter
    showTaskList:showTaskList
