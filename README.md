# Mylyn-for-atom

Task focused development in Atom, based on Mylyn for Eclipse. Mylyn filters the tree view so only files related to a specific task is shown. Files will be automatically removed from the view when not used for a longer period.

## Usage
Enable Mylyn through command pallete  (mylyn:toggle-enabled)

Add a task, or tasks  (mylyn:new-task)

Start working..select files either through command pallete or by switching off filtering  (mylyn:toggle-filter), then add files using the file tree view.


When you have the files you need, toogle filter again.

Tasks will be automatically saved when you exit Atom (to ~/.config/mylyn.json)






## Commands

```
mylyn:toggle-enabled
```
Toggles Mylyn on/off.
```

mylyn:toggle-filter
```
Enable filtered view. If filtering is off, Mylyn will still garther file usage information, but will not filter the tree view. When enabled, Mylyn is also turned on (but not off, when off is selected).


```
mylyn:tasklist
```
Let user pick active task. Enables filtering and Mylyn as well (if not already enabled)
```
mylyn:new-task
```
Create a new task
```
mylyn:delete-all-tasks
```
Deletes all tasks
```
mylyn:delete-task'
```
Delete a specific task
```
mylyn:rename-current-task
```
Renames current task
