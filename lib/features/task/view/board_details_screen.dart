import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabo/features/task/view/task_assignment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/customTextfield.dart';
import '../../gant_chart_screen.dart';
import '../controller/task_cubit.dart';
import '../controller/task_states.dart';
import '../../../core/di.dart';

class BoardDetailsScreen extends StatefulWidget {
  final String workspaceId;
  final String boardId;
  final String boardName;

  const BoardDetailsScreen({
    super.key,
    required this.workspaceId,
    required this.boardId,
    required this.boardName,
  });

  @override
  State<BoardDetailsScreen> createState() => _BoardDetailsScreenState();
}

class _BoardDetailsScreenState extends State<BoardDetailsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;

  final formKey = GlobalKey<FormState>();
  bool _isFormVisible = false;
  bool _isTaskListVisible = false;

  final List<String> columns = ['todo', 'inProgress', 'done'];
  final Map<String, String> columnTitles = {
    'todo': 'To Do',
    'inProgress': 'In Progress',
    'done': 'Done',
  };
  final Map<String, Color> getStatusColor = {
    'todo': Colors.grey.shade200,
    'inProgress': Colors.yellow.shade100,
    'done': Colors.greenAccent.shade100,
  };

  void _toggleForm() {
    setState(() {
      _isFormVisible = !_isFormVisible;
    });
  }

  void _toggleTaskList() {
    setState(() {
      _isTaskListVisible = !_isTaskListVisible;
    });
  }

  Future<String> getUsernames(List<String> uids) async {
    final usernames = <String>[];
    for (final uid in uids) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final username = userDoc.data()?['username'] as String? ?? 'Unknown';
      usernames.add(username);
    }
    return usernames.join(', ');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GanttChartScreen(
                        workspaceId: widget.workspaceId,
                        boardId: widget.boardId,
                        boardName: widget.boardName,
                      ),
                ),
              );
            },
            tooltip: 'View Gantt Chart',
          ),
        ],
      ),
      floatingActionButton:
          !_isTaskListVisible
              ? FloatingActionButton(
                onPressed: _toggleForm,
                backgroundColor: Colors.blueGrey.shade300,
                child: Icon(
                  _isFormVisible ? Icons.close : Icons.add,
                  color: Colors.white,
                ),
              )
              : FloatingActionButton(
                backgroundColor: Colors.redAccent.shade400,

                onPressed: () {
                  _toggleTaskList();
                },
                child: const Icon(Icons.close, size: 30, color: Colors.white),
              ),
      body: BlocProvider(
        create:
            (context) =>
                sl<TaskCubit>()
                  ..listenToTasks(widget.workspaceId, widget.boardId),
        child: BlocConsumer<TaskCubit, TaskStates>(
          listener: (context, state) {
            if (state is TaskCreatedState) {
              Fluttertoast.showToast(
                msg: 'Task created successfully',
                backgroundColor: Colors.green,
              );
              titleController.clear();
              descriptionController.clear();
              _toggleForm();
            } else if (state is TaskErrorState) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            }

            if (state is TaskDeletedState) {
              Fluttertoast.showToast(
                msg: 'Task deleted successfully',
                backgroundColor: Colors.amber,
              );
            }

            if (state is TaskUpdatedState) {
              Fluttertoast.showToast(msg: 'Task updated successfully');
            }
          },
          builder: (context, state) {
            if (state is TaskLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskSuccessState) {
              // Group tasks by status
              final Map<String, List<dynamic>> tasksByStatus = {
                'todo': [],
                'inProgress': [],
                'done': [],
              };

              for (final task in state.tasks) {
                if (tasksByStatus.containsKey(task.status)) {
                  tasksByStatus[task.status]!.add(task);
                } else {
                  // Default if status is unknown
                  tasksByStatus['todo']!.add(task);
                }
              }

              return !_isTaskListVisible
                  ? Stack(
                    children: [
                      Positioned(
                        right: 10,
                        top: 10,
                        child: IconButton(
                          onPressed: () {
                            _toggleTaskList();
                          },
                          icon: const Icon(
                            size: 35,
                            Icons.list,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade500,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Kanban Board',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Tasks',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                state.tasks.isEmpty
                                    ? const Center(
                                      child: Text('No tasks found. Create one'),
                                    )
                                    : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            columns.map((columnId) {
                                              return SizedBox(
                                                width: 300,
                                                child: _buildColumn(
                                                  context,
                                                  columnId,
                                                  tasksByStatus[columnId]!,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                      if (_isFormVisible) _buildTaskForm(context),
                    ],
                  )
                  : Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final createdDate = DateFormat(
                          'MMM dd, yyyy',
                        ).format(state.tasks[index].createdAt.toDate());
                        final task = state.tasks[index];
                        final dueDate =
                            task.dueDate != null
                                ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(task.dueDate!.toDate())
                                : 'No due date';
                        return Card(
                          color: getStatusColor[task.status],
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.description,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    task.status.isNotEmpty
                                        ? Text(
                                          'Status: ${task.status.replaceFirst(task.status[0], task.status[0].toUpperCase())}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue,
                                          ),
                                        )
                                        : const Text(
                                          "Status: Not set",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                  ],
                                ),
                                const SizedBox(height: 2),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Due date: ${dueDate.replaceFirst(dueDate[0], dueDate[0].toUpperCase())}',
                                      style: TextStyle(
                                        color: Colors.redAccent.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.watch_later_outlined,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Created At: ${createdDate.toString()}",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),

                                FutureBuilder<String>(
                                  future: getUsernames(task.assignedUserIds),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 15,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Assigned: ${snapshot.data?.replaceFirst(snapshot.data![0], snapshot.data![0].toUpperCase())}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('Assigned: Loading...');
                                  },
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _deleteDialog(context, task.taskId);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return TaskAssignmentScreen(
                                            workspaceId: widget.workspaceId,
                                            boardId: widget.boardId,
                                            taskId: task.taskId,
                                            currentAssignees:
                                                task.assignedUserIds,
                                            currentDueDate:
                                                task.dueDate?.toDate(),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_right,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TaskAssignmentScreen(
                                        workspaceId: widget.workspaceId,
                                        boardId: widget.boardId,
                                        taskId: task.taskId,
                                        currentAssignees: task.assignedUserIds,
                                        currentDueDate: task.dueDate?.toDate(),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
            } else if (state is TaskErrorState) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String columnId, List tasks) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: getStatusColor[columnId],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: double.infinity,
      child: DragTarget<Map<String, dynamic>>(
        builder: (context, candidateData, rejectedData) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor[columnId]!.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      columnTitles[columnId]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color:
                        candidateData.isNotEmpty
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.transparent,
                  ),
                  child:
                      tasks.isEmpty
                          ? Center(
                            child: Text(
                              'No tasks',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return _buildTaskCard(context, task, columnId);
                            },
                          ),
                ),
              ),
            ],
          );
        },
        onWillAcceptWithDetails: (data) {
          // Accept the drag if the task is from a different column
          return data.data['status'] != columnId;
        },
        onAcceptWithDetails: (data) {
          // Provide haptic feedback on successful drop
          HapticFeedback.lightImpact();

          // Update the task status when dropped into a new column
          context.read<TaskCubit>().updateTaskStatus(
            workspaceId: widget.workspaceId,
            boardId: widget.boardId,
            taskId: data.data['taskId'], // Use the task ID from the drag data
            status: columnId,
          );
        },
        // Visual feedback when hovering over the target
        onMove: (_) {
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, dynamic task, String columnId) {
    final createdDate = DateFormat(
      'MMM dd, yyyy',
    ).format(task.createdAt.toDate());
    final dueDate =
        task.dueDate != null
            ? DateFormat('MMM dd, yyyy').format(task.dueDate!.toDate())
            : 'No due date';

    return LongPressDraggable<Map<String, dynamic>>(
      maxSimultaneousDrags: 1,
      hitTestBehavior: HitTestBehavior.opaque,
      // Data to pass when dragging
      data: {'taskId': task.taskId, 'status': task.status},
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Transform.scale(
          scale: 1.2,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: getStatusColor[task.status],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
      // What remains while dragging
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Card(
          color: getStatusColor[task.status],
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Container(padding: const EdgeInsets.all(8.0)),
        ),
      ),

      child: Card(
        elevation: 5,
        shadowColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: const Text('Edit'),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 50),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TaskAssignmentScreen(
                                            workspaceId: widget.workspaceId,
                                            boardId: widget.boardId,
                                            taskId: task.taskId,
                                            currentAssignees:
                                                task.assignedUserIds,
                                            currentDueDate:
                                                task.dueDate?.toDate(),
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: const Text('Delete'),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 50),
                                () {
                                  _deleteDialog(context, task.taskId);
                                },
                              );
                            },
                          ),
                        ],
                  ),
                ],
              ),
              Text(
                task.description,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 14,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            dueDate,
                            style: TextStyle(
                              color: Colors.redAccent.shade700,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Assignees
                  Expanded(
                    child: FutureBuilder<String>(
                      future: getUsernames(task.assignedUserIds),
                      builder: (context, snapshot) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                snapshot.hasData
                                    ? snapshot.data!.replaceFirst(
                                      snapshot.data![0],
                                      snapshot.data![0].toUpperCase(),
                                    )
                                    : '...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.create, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      "Created At: $createdDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onDragStarted: () {
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildTaskForm(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              opacity: _isFormVisible ? 1.0 : 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create New Task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: titleController,
                        labelText: 'Task Title',
                        prefixIcon: Icons.title,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        controller: descriptionController,
                        labelText: 'Description',
                        prefixIcon: Icons.description_outlined,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Description is required'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _toggleForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  context.read<TaskCubit>().createTask(
                                    workspaceId: widget.workspaceId,
                                    boardId: widget.boardId,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    status: 'todo',
                                    dueDate: selectedDate,
                                    assignedUserIds: [],
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Create'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () async {
                            _selectDate();
                          },
                          icon: const Icon(Icons.date_range_outlined, size: 22),
                          label: const Center(
                            child: Text(
                              "Pick Due Date",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _deleteDialog(BuildContext context, String taskId) async {
    return showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              "Are you sure you want to delete?",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("No", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  context.read<TaskCubit>().deleteTask(
                    workspaceId: widget.workspaceId,
                    boardId: widget.boardId,
                    taskId: taskId,
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text("Yes", style: TextStyle(fontSize: 18)),
              ),
            ],
            icon: const Icon(Icons.delete, size: 35, color: Colors.red),
          ),
    );
  }
}
