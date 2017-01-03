{Disposable,Emitter, CompositeDisposable} = require 'event-kit'
{Mylyn} = require "./mylyn"
{requirePackages} = require 'atom-utils'
module.exports =
  treeView: null
  observer: null
  mylyn:null

  activateMylyn:(state) ->
    if state
      state = state.mylyn
    #state = null
    console.log state
    #state = null
    requirePackages('tree-view').then ([treeView]) =>
        @mylyn = new Mylyn(treeView,state)
  activate: (@state) ->
    @activateMylyn(@state)
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add('atom-workspace', {
      'mylyn:toggle-filter': =>@mylyn.toggleFilter()
      'mylyn:tasklist': =>@mylyn.switchTask()
      'mylyn:new-task': =>@mylyn.newTask()
      'mylyn:delete-all-tasks': =>@mylyn.deleteAllTasks()
      'mylyn:delete-task': =>@mylyn.deleteTaskConfirm()
      'mylyn:rename-current-task': =>@mylyn.renameCurrentTaskConfirm()
      'mylyn:toggle-enabled': =>@mylyn.toggleEnabled()
    })

  deactivate: ->
    @disposables.dispose()

  serialize: ->
    {
        mylyn:@mylyn.getState()
    }
