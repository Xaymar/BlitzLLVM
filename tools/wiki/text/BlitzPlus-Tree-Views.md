## AddTreeViewNode
Adds a node at the end of the children of another node. To add one at the top level, give [TreeViewRoot](BlitzPlus-Tree-Views#treeviewroot) as the parent.

```blitzbasic
;media interact treeviews/addtreeviewnode.png 1
Graphics 320, 240, 32, 2
win  = CreateWindow("Files", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
root = TreeViewRoot(tree)
docs = AddTreeViewNode("Documents", root)
AddTreeViewNode "Letter.txt", docs
AddTreeViewNode "Notes.txt", docs
AddTreeViewNode "Pictures", root
ExpandTreeViewNode docs
Repeat
Until WaitEvent() = $803
```

![AddTreeViewNode](media/treeviews/addtreeviewnode.png)
@param text    Text of the node.
@param parent  The node it goes into.
@param icon    Number of an icon of the tree. Defaults to -1, which means none.
@returns A handle for the new node.

## CollapseTreeViewNode
Folds a node so its children are hidden. They keep existing, and [ExpandTreeViewNode](BlitzPlus-Tree-Views#expandtreeviewnode) shows them again. A node deep in the tree is only seen when everything above it is open.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Fold", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
a = AddTreeViewNode("Branch", TreeViewRoot(tree))
AddTreeViewNode "Leaf", a
ExpandTreeViewNode a
CollapseTreeViewNode a
Repeat
Until WaitEvent() = $803
```
@param node  Handle of a node.

## CountTreeViewNodes
Counts the children a node has directly, without the nodes below them.
@param node  Handle of a node, or the root.
@returns The number of children.

## CreateTreeView
Makes a list of nodes that can be opened and closed, like a folder view. Clicking a node sends $401 with the tree as the source, and [SelectedTreeViewNode](BlitzPlus-Tree-Views#selectedtreeviewnode) tells which. The tree starts out empty: add nodes below the node that [TreeViewRoot](BlitzPlus-Tree-Views#treeviewroot) gives.

```blitzbasic
;media interact treeviews/createtreeview.gif 1
;media click 38 53
;media click 70 77
Graphics 320, 240, 32, 2
win  = CreateWindow("Tree", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
fruit = AddTreeViewNode("Fruit", TreeViewRoot(tree))
AddTreeViewNode "Apple", fruit
AddTreeViewNode "Pear", fruit
Repeat
	e = WaitEvent()
	If e = $401 Then SetGadgetText win, "Node " + TreeViewNodeText(SelectedTreeViewNode(tree))
Until e = $803
```

![CreateTreeView](media/treeviews/createtreeview.gif)
@param x       Horizontal position inside the group.
@param y       Vertical position inside the group.
@param width   Width of the tree.
@param height  Height of the tree.
@param group   Window, panel, tabber or canvas that holds it.
@param style   0, or 65536 to not follow the group when it is resized. Defaults to 0.
@returns A handle for the tree view.

## ExpandTreeViewNode
Opens a node so that its children are seen. See [CollapseTreeViewNode](BlitzPlus-Tree-Views#collapsetreeviewnode).
@param node  Handle of a node.

## FreeTreeViewNode
Removes a node together with all nodes below it. The root must not be freed.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Free", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
a = AddTreeViewNode("Keep", TreeViewRoot(tree))
b = AddTreeViewNode("Remove", TreeViewRoot(tree))
FreeTreeViewNode b
Repeat
Until WaitEvent() = $803
```
@param node  Handle of a node.

## InsertTreeViewNode
Puts a node before the child with the given number of a parent.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Insert", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
root = TreeViewRoot(tree)
AddTreeViewNode "First", root
AddTreeViewNode "Third", root
InsertTreeViewNode 1, "Second", root
Repeat
Until WaitEvent() = $803
```
@param index   Where the node goes among the children, starting at 0.
@param text    Text of the node.
@param parent  The node it goes into.
@param icon    Number of an icon of the tree. Defaults to -1, which means none.
@returns A handle for the new node.

## ModifyTreeViewNode
Changes the text of a node.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Modify", 10, 10, 300, 200, Desktop(), 3)
tree = CreateTreeView(10, 10, 270, 140, win)
n = AddTreeViewNode("Old", TreeViewRoot(tree))
ModifyTreeViewNode n, "New"
Repeat
Until WaitEvent() = $803
```
@param node  Handle of a node.
@param text  The new text.
@param icon  Number of an icon of the tree. Defaults to -1, which means none.

## SelectedTreeViewNode
@param treeview  Handle of a tree view.
@returns The handle of the selected node, or 0 if none is selected.

## SelectTreeViewNode
Selects a node, as if the user clicked it. There is no way to remove the selection afterwards other than selecting another node.
@param node  Handle of a node.

## TreeViewNodeText
@param node  Handle of a node.
@returns The text of the node.

## TreeViewRoot
Gives the invisible node at the top of a tree. It is the parent of the top level nodes and cannot be freed or selected.
@param treeview  Handle of a tree view.
@returns The handle of the root node.
