{Disposable,Emitter, CompositeDisposable} = require 'event-kit'
{Mylyn} = require "./mylyn"
path = require 'path'
{requirePackages} = require 'atom-utils'
module.exports =
  treeView: null
  observer: null
  mylyn:null

  activateMylyn:(state) ->
    if state
      state = state.mylyn
    requirePackages('tree-view').then ([treeView]) =>
        @mylyn = new Mylyn(treeView,state)
  activate: (@state) ->
    @activateMylyn(@state)
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add('atom-workspace', {
      'mylyn:toogle-filter': =>
        @mylyn.toggleFilter()

      'mylyn:tasklist': =>@mylyn.showTaskList()
      'mylyn:new-task': =>@mylyn.newTask()
      'mylyn:delete-task': =>@mylyn.deleteTaskConfirm()
      'mylyn:rename-current-task': =>@mylyn.renameCurrentTask()
    })

  deactivate: ->
    @disposables.dispose()

  serialize: ->
    {
        mylyn:@mylyn.getState()
    }
