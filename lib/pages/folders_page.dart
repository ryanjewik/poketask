import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_details_card.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final List<Task> tasks = [
    Task(
      eventName: 'Discuss project requirements',
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'Go over the main features and deadlines.',
      threadId: 1,
      folderId: 1,
    ),
    Task(
      eventName: 'Review code',
      from: DateTime.now().add(Duration(hours: 2)),
      to: DateTime.now().add(Duration(hours: 3)),
      notes: 'Check the latest PRs and leave comments.',
      threadId: 1,
      isCompleted: true,
      folderId: 2,
    ),
    Task(
      eventName: 'Write documentation',
      from: DateTime.now().add(Duration(hours: 4)),
      to: DateTime.now().add(Duration(hours: 5)),
      notes: 'Document the new API endpoints.',
      threadId: 1,
      folderId: 2,
    ),
    Task(
      eventName: 'Team meeting',
      from: DateTime.now().add(Duration(hours: 6)),
      to: DateTime.now().add(Duration(hours: 7)),
      notes: 'Weekly sync with the whole team.',
      threadId: 2,
      folderId: 3,
      highPriority: true,
    ),
    Task(
      eventName: 'design battle system',
      from: DateTime.now().subtract(Duration(hours: 2)),
      to: DateTime.now().subtract(Duration(hours: 1)),
      notes: 'how will the min max AI work',
      threadId: 1,
    ),
  ];

  final List<Map<String, dynamic>> folders = [
    {'id': 0, 'name': 'No Folder'},
    {'id': 1, 'name': 'Design'},
    {'id': 2, 'name': 'Development'},
    {'id': 3, 'name': 'Meetings'},
  ];
  int? expandedFolderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Folders'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar for folders
          Container(
            width: 160,
            color: Colors.grey[300],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.create_new_folder, size: 20),
                    label: Text('Add Folder', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 36),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onPressed: () async {
                      final controller = TextEditingController();
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('New Folder'),
                          content: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(hintText: 'Folder name'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  Navigator.of(context).pop(controller.text.trim());
                                }
                              },
                              child: Text('Add'),
                            ),
                          ],
                        ),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          final newId = (folders.isNotEmpty ? folders.map((f) => f['id'] as int).reduce((a, b) => a > b ? a : b) : 0) + 1;
                          folders.add({'id': newId, 'name': result});
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView(
                        children: folders.map((folder) {
                          final isExpanded = expandedFolderId == folder['id'];
                          String folderName = folder['name'];
                          double fontSize = 15;
                          final textPainter = TextPainter(
                            text: TextSpan(text: folderName, style: TextStyle(fontSize: fontSize)),
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          );
                          textPainter.layout(maxWidth: constraints.maxWidth - 48);
                          while (textPainter.didExceedMaxLines && fontSize > 10) {
                            fontSize -= 1;
                            textPainter.text = TextSpan(text: folderName, style: TextStyle(fontSize: fontSize));
                            textPainter.layout(maxWidth: constraints.maxWidth - 48);
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: Dismissible(
                                  key: ValueKey(folder['id']),
                                  direction: folder['id'] != 0 ? DismissDirection.endToStart : DismissDirection.none,
                                  background: Container(
                                    color: Colors.redAccent,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: folder['id'] != 0
                                      ? (direction) async {
                                          return await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Delete Folder'),
                                              content: Text('Are you sure you want to delete the folder "$folderName"? All tasks in this folder will be moved to "No Folder".'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : null,
                                  onDismissed: (direction) {
                                    setState(() {
                                      for (final t in tasks) {
                                        if (t.folderId == folder['id']) {
                                          t.folderId = 0;
                                        }
                                      }
                                      folders.removeWhere((f) => f['id'] == folder['id']);
                                      if (expandedFolderId == folder['id']) expandedFolderId = null;
                                    });
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.folder, color: folder['id'] == 0 ? Colors.grey : Colors.redAccent),
                                    title: Text(
                                      folderName,
                                      style: TextStyle(fontSize: fontSize),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                    selected: isExpanded,
                                    onTap: () {
                                      setState(() {
                                        expandedFolderId = isExpanded ? null : folder['id'];
                                      });
                                    },
                                    onLongPress: folder['id'] != 0
                                        ? () async {
                                            final action = await showModalBottomSheet<String>(
                                              context: context,
                                              builder: (context) => SafeArea(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: Icon(Icons.edit),
                                                      title: Text('Rename'),
                                                      onTap: () => Navigator.of(context).pop('rename'),
                                                    ),
                                                    ListTile(
                                                      leading: Icon(Icons.delete, color: Colors.redAccent),
                                                      title: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                      onTap: () => Navigator.of(context).pop('delete'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            if (action == 'rename') {
                                              final controller = TextEditingController(text: folderName);
                                              final newName = await showDialog<String>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Rename Folder'),
                                                  content: TextField(
                                                    controller: controller,
                                                    autofocus: true,
                                                    decoration: InputDecoration(hintText: 'Folder name'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (controller.text.trim().isNotEmpty) {
                                                          Navigator.of(context).pop(controller.text.trim());
                                                        }
                                                      },
                                                      child: Text('Rename'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (newName != null && newName.isNotEmpty && newName != folderName) {
                                                setState(() {
                                                  folder['name'] = newName;
                                                });
                                              }
                                            } else if (action == 'delete') {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Delete Folder'),
                                                  content: Text('Are you sure you want to delete the folder "$folderName"? All tasks in this folder will be moved to "No Folder".'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                      child: Text('Delete', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                setState(() {
                                                  for (final t in tasks) {
                                                    if (t.folderId == folder['id']) {
                                                      t.folderId = 0;
                                                    }
                                                  }
                                                  folders.removeWhere((f) => f['id'] == folder['id']);
                                                  if (expandedFolderId == folder['id']) expandedFolderId = null;
                                                });
                                              }
                                            }
                                          }
                                        : null,
                                    trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    minVerticalPadding: 0,
                                    dense: true,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main area for tasks in selected folder
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: expandedFolderId == null
                  ? Center(child: Text('Select a folder to view tasks'))
                  : AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      child: ListView.builder(
                        key: ValueKey(expandedFolderId),
                        padding: EdgeInsets.all(10),
                        itemCount: tasks.where((task) => task.folderId == expandedFolderId).length,
                        itemBuilder: (context, idx) {
                          final visibleTasks = tasks.where((task) => task.folderId == expandedFolderId).toList();
                          final task = visibleTasks[idx];
                          return TweenAnimationBuilder<Offset>(
                            tween: Tween(
                              begin: Offset(0, 0.3 + 0.1 * (visibleTasks.length - idx)),
                              end: Offset.zero,
                            ),
                            duration: Duration(milliseconds: 350 + idx * 80),
                            curve: Curves.easeOut,
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: Offset(0, offset.dy * 60),
                                child: child,
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (task.highPriority == true)
                                    Container(
                                      color: Colors.red[700],
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.priority_high, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'High Priority',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (task.to.isBefore(DateTime.now()))
                                    Container(
                                      color: Colors.orange[800],
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'Past Deadline',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: InkWell(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => TaskDetailsCard(task: task),
                                        );
                                        setState(() {});
                                      },
                                      child: ListTile(
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: task.isCompleted ? Colors.green : Colors.grey,
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          task.eventName.replaceAll(' ', '\n'),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 18, height: 1.2),
                                          softWrap: true,
                                        ),
                                        subtitle: Text(
                                          task.notes,
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
