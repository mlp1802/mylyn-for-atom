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
      'list:toogle-filter': =>
        @mylyn.toggleFilter()

      'list:tasklist': =>@mylyn.showTaskList()
      'list:new-task': =>@mylyn.newTask()
      'list:delete-task': =>@mylyn.deleteTaskConfirm()
      'list:rename-current-task': =>@mylyn.renameCurrentTask()
    })

  deactivate: ->
    @disposables.dispose()
  consumeFileIcons: (service) ->
    FileIcons.setService(service)
    @treeView?.updateRoots()
    new Disposable =>
      FileIcons.resetService()
      @treeView?.updateRoots()

  serialize: ->
    {
        mylyn:@mylyn.getState()
    }
