import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../services/task_details_card.dart';
import '../services/task_form.dart';

class FoldersPage extends StatefulWidget {
  final String trainerId;
  const FoldersPage({super.key, required this.trainerId});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final List<Task> tasks = [

  ];

  List<Map<String, dynamic>> folders = [];
  String? expandedFolderId;

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('folder_table')
        .select()
        .eq('trainer_id', widget.trainerId);
    setState(() {
      folders = [
        {'folder_id': '0', 'folder_name': 'No Folder'},
        ...List<Map<String, dynamic>>.from(response)
      ];
    });
  }

  void onFolderSelected(String? folderId) async {
    setState(() {
      expandedFolderId = folderId;
      tasks.clear();
    });
    final supabase = Supabase.instance.client;
    List response;
    if (folderId == null || folderId == '0') {
      response = await supabase
          .from('task_table')
          .select()
          .eq('trainer_id', widget.trainerId);
      print('Fetched tasks for trainer_id: \\${widget.trainerId} => \\${response.length} tasks');
      // Filter for tasks with folder_id == null
      response = response.where((t) => t['folder_id'] == null).toList();
      print('Filtered tasks with folder_id == null: \\${response.length} tasks');
    } else {
      response = await supabase
          .from('task_table')
          .select()
          .eq('trainer_id', widget.trainerId)
          .eq('folder_id', folderId);
    }
    setState(() {
      tasks.clear();
      for (final t in response) {
        tasks.add(Task.fromJson(t));
      }
    });
  }

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
                      Color selectedColor = Colors.blue; // Default color
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              title: Text('New Folder'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: controller,
                                    autofocus: true,
                                    decoration: InputDecoration(hintText: 'Folder name'),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text('Color:'),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          Color? picked = await showDialog<Color>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Pick a color'),
                                              content: SingleChildScrollView(
                                                child: BlockPicker(
                                                  pickerColor: selectedColor,
                                                  onColorChanged: (color) {
                                                    Navigator.of(context).pop(color);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                          if (picked != null) {
                                            setState(() => selectedColor = picked);
                                          }
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: selectedColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.black26),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (controller.text.trim().isNotEmpty) {
                                      Navigator.of(context).pop({
                                        'folder_name': controller.text.trim(),
                                        'color': selectedColor.value,
                                      });
                                    }
                                  },
                                  child: Text('Add'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (result != null && result['folder_name'].isNotEmpty) {
                        final uuid = Uuid();
                        final folderId = uuid.v4();
                        final folderName = result['folder_name'];
                        final colorValue = result['color'];
                        final trainerId = widget.trainerId;
                        // Convert color int to hex string with #
                        final colorHex = '#'
                            + colorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
                        // Insert into database
                        final supabase = Supabase.instance.client;
                        await supabase.from('folder_table').insert({
                          'folder_id': folderId,
                          'folder_name': folderName,
                          'trainer_id': trainerId,
                          'color': colorHex,
                        });
                        // Add to local list
                        setState(() {
                          folders.add({
                            'folder_id': folderId,
                            'folder_name': folderName,
                            'trainer_id': trainerId,
                            'color': colorHex,
                          });
                        });

                      }
                    },
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                          children: folders.map((folder) {
                            final folderId = (folder['folder_id'] ?? '0').toString();
                            final isExpanded = expandedFolderId == folderId;
                            String folderName = (folder['folder_name'] ?? 'Unnamed Folder').toString();
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
                                    key: ValueKey(folderId),
                                    direction: folderId != '0' ? DismissDirection.endToStart : DismissDirection.none,
                                    background: Container(
                                      color: Colors.redAccent,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Icon(Icons.delete, color: Colors.white),
                                    ),
                                    confirmDismiss: folderId != '0'
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
                                          if (t.folderId == folderId) {
                                            t.folderId = '0';
                                          }
                                        }
                                        folders.removeWhere((f) => f['folder_id'] == folder['folder_id']);
                                        if (expandedFolderId == folderId) expandedFolderId = null;
                                      });
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.folder,
                                        color: folderId == '0'
                                            ? Colors.grey
                                            : (folder['color'] != null && folder['color'] is String && (folder['color'] as String).startsWith('#')
                                                ? Color(int.parse((folder['color'] as String).replaceFirst('#', '0xff')))
                                                : Colors.redAccent),
                                      ),
                                      title: Text(
                                        folderName,
                                        style: TextStyle(fontSize: fontSize),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      selected: isExpanded,
                                      onTap: () {
                                        onFolderSelected(isExpanded ? null : folderId);
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
                                                      if (t.folderId == folder['id'].toString()) {
                                                        t.folderId = '0';
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
                                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 0), // Reduced horizontal padding
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
                ),
                // Remove Spacer(), keep Add Task button at the bottom
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 16, // Add extra space above system nav bar
                    top: 8.0,
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add_task),
                    label: Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 40),
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskForm(
                            trainerId: widget.trainerId,
                            onSubmit: (task) {
                              onFolderSelected(expandedFolderId);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
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
                        itemCount: expandedFolderId == '0'
                            ? tasks.where((task) => task.folderId == null).length
                            : tasks.where((task) => task.folderId == expandedFolderId?.toString()).length,
                        itemBuilder: (context, idx) {
                          final visibleTasks = expandedFolderId == '0'
                              ? tasks.where((task) => task.folderId == null).toList()
                              : tasks.where((task) => task.folderId == expandedFolderId?.toString()).toList();
                          final task = visibleTasks[idx];
                          return TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
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
                                        leading: Icon(
                                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: task.isCompleted ? Colors.green : Colors.grey,
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
