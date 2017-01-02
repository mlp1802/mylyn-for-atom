{TaskList} = require("./TaskList")
{$} = require('atom-space-pen-views')
FileIcons = require './file-icons'
InputDialog = require '@aki77/atom-input-dialog'
view = null
class Mylyn
  observer:null
  constructor:(@view,@mylyn)->
    if !@mylyn
        @mylyn =
              currentTask:null
              tasks:[]
              filterOn:false
    @observer =  atom.workspace.onDidChangeActivePaneItem((e)=>
        @onDidChangeActivePaneItem(e)
        )
    @reloadTreeView()

  toRelPath:(path)->atom.project.relativizePath(path)[1]
  deleteTask:(task)=>
      @mylyn.tasks = @mylyn.tasks.filter (t)->t!=task
      if @mylyn.currentTask==task then @mylyn.currentTask=null
      @focusActivePane()

  filterOn: =>
    #return false
    @mylyn.filterOn&@mylyn.currentTask!=null

  focusActivePane:=>
      active =  atom.workspace.getActivePane()
      if active then active.activate()

  createTask:(name)=>
      task =
              name:name
              files:[]
      @mylyn.tasks.push(task)
      task



  reloadTreeView:()=>
      console.log(@view)
      @view.createView().updateRoots()

      @view.treeView.roots.forEach (r)=>
          #console.log "RELOAD",r.directory
          #r.directory.reload()
      @rebuild()

  showTaskList:()=>
    tasklist = new TaskList @mylyn.currentTask, @mylyn.tasks,(task)=>
        @mylyn.currentTask = task
        @reloadTreeView()
        @focusActivePane()
    console.log(tasklist)


  getFiles: ()=>
    if @mylyn.currentTask
      @mylyn.currentTask.files
    else
      []

  isDirAllowed:(dir)=>
      #return false
      if @filterOn()
        dir = @toRelPath(dir)
        @getFiles().find((file)->(""+file).startsWith(dir))!=undefined
      else
        true

  isFileAllowed:(file)=>
    #return false
    if @filterOn()
      relFile = @toRelPath(file)
      #out("RelFile")(relFile)
      #out("Files")(getFiles())
      relFile in @getFiles()
    else
      true

  addFile:(file)=>
        @getFiles().push(file)


  renameTask:(task,newName)=>
      @mylyn.currentTask.name = newName

  renameCurrentTaskConfirm:()=>
    if @mylyn.currentTask==null then return
    dialog = new InputDialog
          prompt:"Rename task "+mylyn.currentTask.name
          defaultText:mylyn.currentTask.name
          callback: (name) ->
              @renameTask(mylyn.currentTask,name)
              @focusActivePane()


  deleteTaskConfirm:()=>
    tasklist = new TaskList @mylyn.currentTask, @mylyn.tasks,(task)=>
        @deleteTask(task)
        @reloadTreeView()
        @focusActivePane()
    console.log(tasklist)


  newTask:() =>
    dialog = new InputDialog
          prompt:"New task"
          defaultText:""
          callback: (text) =>
              @mylyn.currentTask = @createTask(text)
              #@view.createView().updateRoots()
              #console.log @view
              @reloadTreeView()
              #@rebuild()
              @focusActivePane()

    dialog.attach()


  getState:()->@mylyn


  out:(o)=>
      console.log o
      @out


  hide: (e,isAllowed)=>
    span = $(e).find("span").first()
    path = $(span).attr("data-path")

    if !isAllowed(path)
        #$(e).addClass("mylyn-hidden")
        $(e).remove()
        #$(e).detach()
    #else
        #$(e).attach()
    #    $(e).removeClass("mylyn-hidden")



  hideDir:(e)=>
      @hide(e,@isDirAllowed)

  hideFile:(e)=>
      @hide(e,@isFileAllowed)

  hideDirs:=>
      dirs = @getDomDirs()
      dirs.each (i,e)=>@hideDir(e)
  hideFiles:=>
      files = @getDomFiles()
      files.each (i,e)=>@hideFile(e)

  listenForEvents:(entry)->
      if entry.onDidExpand
          entry.onDidExpand((d)=>@rebuild())
      if entry.entries
          #$.each entry.entries, (key, value)->console.log(key, value)
          $.each entry.entries, (key, value)=>@listenForEvents value
          #@out("entr")(entry.entries)
          #entry.entries.forEach @listenForEvents
  rebuild:()=>
    #@out("View")(@view)
    @hideDirs()
    @hideFiles()
    #emitter = @view.treeView.roots[0].directory.emitter
    #onDidExpand
    @view.treeView.roots.forEach (root)=>@listenForEvents root.directory

    rootDir = @view.treeView.roots[0].directory

    #@out("Emitter")(emitter)

  getDomFiles: =>
    files = $(".tree-view [is='tree-view-file']")
    files

  getDomDirs: =>
    dirs = $(".tree-view [is='tree-view-directory']")#.css("display","none")
    #print(dirs)
    dirs

  onDidChangeActivePaneItem:(e)->
        workspaceView = atom.views.getView(atom.workspace)
        activeEditor = atom.workspace.getActiveTextEditor()
        if activeEditor
          path =  @toRelPath(activeEditor.getBuffer().getPath())
          @addFile(path)
          @reloadTreeView()
          #@rebuild()
          @focusActivePane()



  toggleFilter:=>
    @mylyn.filterOn = !@mylyn.filterOn
    @reloadTreeView()


module.exports =
    Mylyn:Mylyn
