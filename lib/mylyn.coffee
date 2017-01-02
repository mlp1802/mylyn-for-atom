{TaskList} = require("./TaskList")
{$} = require('atom-space-pen-views')
FileIcons = require './file-icons'
InputDialog = require '@aki77/atom-input-dialog'
view = null
toRelPath = (path)->atom.project.relativizePath(path)[1]

deleteTask = (task) ->
    mylyn.tasks = mylyn.tasks.filter (t)->t!=task
    if mylyn.currentTask==task then mylyn.currentTask=null
    view.updateRoots()
    focusActivePane()

filterOn =->mylyn.filterOn&mylyn.currentTask!=null

focusActivePane = ->
    active =  atom.workspace.getActivePane()
    if active then active.activate()
createTask = (name)->
    task =
            name:name
            files:[]
    mylyn.tasks.push(task)
    task



showTaskList =(view)->
  tasklist = new TaskList mylyn.currentTask, mylyn.tasks,(task)->
      mylyn.currentTask = task
      view.updateRoots()
      #focusActivePane()
  console.log(tasklist)


getFiles = ->
  if mylyn.currentTask
    mylyn.currentTask.files
  else
    []
isDirAllowed = (dir)->
    return true
    if filterOn()
      dir = toRelPath(dir)
      getFiles().find((file)->file.startsWith(dir))!=undefined
    else
      true

isFileAllowed = (file)->
  return true
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

renameTask = (task,newName)->
    mylyn.currentTask.name = newName

renameCurrentTaskConfirm = ()->
  if mylyn.currentTask==null then return
  dialog = new InputDialog
        prompt:"Rename task "+mylyn.currentTask.name
        defaultText:mylyn.currentTask.name
        callback: (name) ->
            renameTask(mylyn.currentTask,name)
            focusActivePane()
  dialog.attach()

deleteTaskConfirm = ()->
  task =  mylyn.currentTask
  if task==null then return
  dialog = new InputDialog
        prompt:"Delete task "+task.name+" ? (yes/no)"
        defaultText:"No"
        callback: (text) ->
            if(text.toLowerCase()=="yes")
              deleteTask(task)
              focusActivePane()
  dialog.attach()
newTask =() ->
  dialog = new InputDialog
        prompt:"New task"
        defaultText:""
        callback: (text) ->
            mylyn.currentTask = createTask(text)
            view.updateRoots()
            focusActivePane()

  dialog.attach()


getMylyn =()->mylyn
onDidChangeActivePaneItem = (e)->
      workspaceView = atom.views.getView(atom.workspace)
      activeEditor = atom.workspace.getActiveTextEditor()
      if activeEditor
        path =  toRelPath(activeEditor.getBuffer().getPath())
        addFile(path)
        console.log("document")
        lol = $("[data-path],[data-name],.icon-file-text")#.css("display","none")
        lol.each (i,e)->console.log($(e).attr("data-path"))
        #console.log(lol)

        #atom.commands.dispatch(workspaceView, 'tree-view:reveal-active-file')
        focusActivePane()


allowedFiles = {
    isDirAllowed:isDirAllowed
    isFileAllowed:isFileAllowed
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
    renameCurrentTask:renameCurrentTaskConfirm
    deleteTask:deleteTaskConfirm
