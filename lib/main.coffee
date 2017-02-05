{Disposable,Emitter, CompositeDisposable} = require 'event-kit'
{Mylyn} = require "./mylyn"
{requirePackages} = require 'atom-utils'
mylyn = null

module.exports =
  mylyn:()=>mylyn
  activateMylyn:(state) ->
    if state
      state = state.mylyn
    requirePackages('tree-view').then ([treeView]) =>
        mylyn = new Mylyn(treeView,state)
  withMylyn:(f)=>
      if mylyn
        f(mylyn)
      else
        requirePackages('tree-view').then ([treeView]) =>
            mylyn = new Mylyn(treeView,state)
            f(mylyn)

  activate: (@state) ->
    @activateMylyn(@state)
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add('atom-workspace', {
      'mylyn:toggle-filter': =>@withMylyn((mylyn)=>mylyn.toggleFilter())
      'mylyn:tasklist': =>@withMylyn((mylyn)=>mylyn.switchTask())
      'mylyn:new-task': =>@withMylyn((mylyn)=>mylyn.newTask())
      'mylyn:delete-all-tasks':=>@withMylyn((mylyn)=>mylyn.deleteAllTasks())
      'mylyn:delete-task': =>@withMylyn((mylyn)=>mylyn.deleteTaskConfirm())
      'mylyn:rename-current-task': =>@withMylyn((mylyn)=>mylyn.renameCurrentTaskConfirm())
      'mylyn:toggle-enabled': =>@withMylyn((mylyn)=>mylyn.toggleEnabled())
    })

  deactivate: ->
    @disposables.dispose()

  serialize: ->
    {
        mylyn:mylyn.getState()
    }
