{TaskList} = require("./TaskList")
{$} = require('atom-space-pen-views')
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
      view = @view.createView()
      selectedPath = view.selectedEntry()?.getPath()
      view.updateRoots()
      if selectedPath
        view.selectEntryForPath selectedPath
      @rebuild()


  selectTask:(callback)=>
    new TaskList @mylyn.currentTask, @mylyn.tasks,(task)=>
        callback(task)
        @focusActivePane()

  switchTask:()=>
    @selectTask (task)=>
      @mylyn.currentTask = task
      @reloadTreeView()




  getFilePaths:()=>
    @getFiles().map (f)->f.path
  isDirAllowed:(dir)=>
      if @filterOn()
        dir = @toRelPath(dir)
        @getFilePaths().find((file)->(""+file).startsWith(dir))!=undefined
      else
        true

  isFileAllowed:(file)=>
    if @filterOn()
      relFile = @toRelPath(file)
      relFile in @getFilePaths()
    else
      true


  withCurrentTask:(f)->
    if @mylyn.currentTask
      f(@mylyn.currentTask)

  getFiles: ()=>
    if @mylyn.currentTask
      @mylyn.currentTask.files
    else
      []

  hasFile:(file)=>
    file in @getFilePaths()

  getFile:(file)=>
    @getFiles().find (f)=>f.path is file

  addFile:(path)=>
        startPoints = 205
        if !@hasFile path
            file =
                path:path
                points:startPoints
            @getFiles().push(file)
          else
            file = @getFile(path)
            file.points=startPoints
        @getFiles().forEach (f)->
            f.points = f.points-5



  renameTask:(task,newName)=>
      @mylyn.currentTask.name = newName

  renameCurrentTaskConfirm:()=>
    if @mylyn.currentTask==null then return
    dialog = new InputDialog
          prompt:"Rename task "+@mylyn.currentTask.name
          defaultText:@mylyn.currentTask.name
          callback: (name) =>
              @renameTask(@mylyn.currentTask,name)
              @focusActivePane()
    dialog.attach()


  deleteTaskConfirm:()=>
    @selectTask (task)=>
        @deleteTask(task)
        @reloadTreeView()


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
        $(e).remove()
        #$(e).replaceWith($('<h5>' + e.innerHTML + '</h5>'));
        #$(e).addClass("mylyn-hidden")

        #$(e).addClass("status-ignored")
        #$(e).removeClass("entry")
    #else

    #    $(e).removeClass("mylyn-hidden")
    #    #$(e).addClass("entry")
    #    $(e).removeClass("status-ignored")


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

    @hideDirs()
    @hideFiles()
    @view.treeView.roots.forEach (root)=>@listenForEvents root.directory
    rootDir = @view.treeView.roots[0].directory

  getDomFiles: =>
    files = $(".tree-view [is='tree-view-file']")
    files

  getDomDirs: =>
    dirs = $(".tree-view [is='tree-view-directory']")#.css("display","none")
    dirs

  removeFile:(file)=>

  updateFiles:()=>

    console.log(@getFiles())
    files = @getFiles().filter (f)->f.points>0
    @withCurrentTask (task)->task.files = files



    #console.log @getFiles()


  onDidChangeActivePaneItem:(e)->
        workspaceView = atom.views.getView(atom.workspace)
        activeEditor = atom.workspace.getActiveTextEditor()

        if activeEditor
          path =  @toRelPath(activeEditor.getBuffer().getPath())
          @addFile(path)
          @updateFiles()


          @reloadTreeView()

  toggleFilter:=>
    @mylyn.filterOn = !@mylyn.filterOn
    @reloadTreeView()

module.exports =
    Mylyn:Mylyn
