{TaskList} = require("./TaskList")
FileIcons = require './file-icons'
InputDialog = require '@aki77/atom-input-dialog'
view = null
toRelPath = (path)->atom.project.relativizePath(path)[1]

deleteTask = (task) ->
    active = atom.workspace.getActivePane()
    mylyn.tasks = mylyn.tasks.filter (t)->t!=task
    if mylyn.currentTask==task then mylyn.currentTask=null
    view.updateRoots()
    if active
      active.activate()
filterOn =->mylyn.filterOn&mylyn.currentTask!=null
addCommands = (task)->
    command = atom.commands.add 'atom-workspace' , 'list:delete-task-'+task.name,()=>
                                        deleteTask(task)
                                        command.dispose()

createTask = (name)->
    task =
            name:name
            files:[]
    mylyn.tasks.push(task)
    addCommands(task)
    task



showTaskList =(view)->
  active = atom.workspace.getActivePane()
  tasklist = new TaskList mylyn.currentTask, mylyn.tasks,(task)->
      mylyn.currentTask = task
      view.updateRoots()
      if active
        active.activate()


getFiles = ->
  if mylyn.currentTask
    mylyn.currentTask.files
  else
    []
isDirAllowed = (dir)->
    if filterOn()
      dir = toRelPath(dir)
      getFiles().find((file)->file.startsWith(dir))!=undefined
    else
      true

isFileAllowed = (file)->
  if filterOn()
    toRelPath(file) in getFiles()
  else
    true

addFile =(file)->
      getFiles().push(file)


mylyn =
      currentTask:null
      tasks:[]
      filterOn:false




setMylyn =(m) ->
    mylyn = m
    mylyn.tasks.forEach (task)->addCommands(task)


renameCurrentTask = ()->
  active = atom.workspace.getActivePane()
  if mylyn.currentTask==null then return
  dialog = new InputDialog
        prompt:"Rename task "+mylyn.currentTask.name
        defaultText:mylyn.currentTask.name
        callback: (text) ->
            mylyn.currentTask.name = text
            active.activate()
  dialog.attach()

newTask =() ->
  active = atom.workspace.getActivePane()
  dialog = new InputDialog
        prompt:"New task"
        defaultText:""
        callback: (text) ->
            mylyn.currentTask = createTask(text)
            view.updateRoots()
            if active
              active.activate()




  dialog.attach()


getMylyn =()->mylyn
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
    getMylyn:getMylyn
    renameCurrentTask:renameCurrentTask
  }


toggleFilter = ->
  mylyn.filterOn = !mylyn.filterOn

setView = (v)->
  view = v
module.exports =
    onDidChangeActivePaneItem:onDidChangeActivePaneItem
    allowedFiles:allowedFiles
    toggleFilter:toggleFilter
    showTaskList:showTaskList
    setMylyn:setMylyn
    getMylyn:getMylyn
    newTask:newTask
    setView:setView
    renameCurrentTask:renameCurrentTask
