import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabo/features/task/view/task_assignment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/customTextfield.dart';
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

  void _toggleForm() {
    setState(() {
      _isFormVisible = !_isFormVisible;
    });
  }

  Future<String> getUsernames(List<String> uids) async {
    final usernames = <String>[];
    for (final uid in uids) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      usernames.add(userDoc.data()!['username']);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleForm,
        backgroundColor: Colors.blueGrey.shade300,
        child: Icon(
          _isFormVisible ? Icons.close : Icons.add,
          color: Colors.white,
        ),
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
          },

          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: [
                    if (state is TaskSuccessState)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          width: 250,
                          height: 65,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade700,
                                Colors.blue.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Tasks',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child:
                          state is TaskLoadingState || state is TaskUpdatedState
                              ? const Center(child: CircularProgressIndicator())
                              : state is TaskSuccessState
                              ? state.tasks.isEmpty
                                  ? const Center(
                                    child: Text('No tasks found. Create one!'),
                                  )
                                  : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: state.tasks.length,
                                    itemBuilder: (context, index) {
                                      final createdDate = DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(
                                        state.tasks[index].createdAt.toDate(),
                                      );
                                      final task = state.tasks[index];
                                      final dueDate =
                                          task.dueDate != null
                                              ? DateFormat(
                                                'MMM dd, yyyy',
                                              ).format(task.dueDate!.toDate())
                                              : 'No due date';
                                      return Card(
                                        color: getStatusColor(task.status),
                                        margin: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            task.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(task.description),
                                              const SizedBox(height: 6),
                                              task.status.isNotEmpty
                                                  ? Text(
                                                    'Status: ${task.status.replaceFirst(task.status[0], task.status[0].toUpperCase())}',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                    ),
                                                  )
                                                  : const Text(
                                                    "Status not set",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                              const SizedBox(height: 2),

                                              Text(
                                                'Due date: ${dueDate.replaceFirst(dueDate[0], dueDate[0].toUpperCase())}',
                                                style: TextStyle(
                                                  color:
                                                      Colors.redAccent.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),

                                              Text(
                                                "Created At: ${createdDate.toString()}",
                                              ),
                                              const SizedBox(height: 2),

                                              FutureBuilder<String>(
                                                future: getUsernames(
                                                  task.assignedUserIds,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Text(
                                                      'Assigned: ${snapshot.data?.replaceFirst(snapshot.data![0], snapshot.data![0].toUpperCase())}',
                                                      style: TextStyle(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                      ),
                                                    );
                                                  }
                                                  return const Text(
                                                    'Assigned: Loading...',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _deleteDialog(
                                                    context,
                                                    task.taskId,
                                                  );
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
                                                          workspaceId:
                                                              widget
                                                                  .workspaceId,
                                                          boardId:
                                                              widget.boardId,
                                                          taskId: task.taskId,
                                                          currentAssignees:
                                                              task.assignedUserIds,
                                                          currentDueDate:
                                                              task.dueDate
                                                                  ?.toDate(),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_double_arrow_right,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => TaskAssignmentScreen(
                                                      workspaceId:
                                                          widget.workspaceId,
                                                      boardId: widget.boardId,
                                                      taskId: task.taskId,
                                                      currentAssignees:
                                                          task.assignedUserIds,
                                                      currentDueDate:
                                                          task.dueDate
                                                              ?.toDate(),
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                              : state is TaskErrorState
                              ? Center(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              )
                              : const SizedBox(),
                    ),
                  ],
                ),
                if (_isFormVisible)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: SingleChildScrollView(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextFormField(
                                    controller: titleController,
                                    labelText: 'Task Title',
                                    prefixIcon: Icons.title,
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? 'Title is required'
                                                : null,
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
                                            if (formKey.currentState!
                                                .validate()) {
                                              context
                                                  .read<TaskCubit>()
                                                  .createTask(
                                                    workspaceId:
                                                        widget.workspaceId,

                                                    boardId: widget.boardId,
                                                    title: titleController.text,
                                                    description:
                                                        descriptionController
                                                            .text,
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
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.5,

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
                                      icon: const Icon(
                                        Icons.date_range_outlined,
                                        size: 22,
                                      ),
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
              ],
            );
          },
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

    setState(() {
      selectedDate = pickedDate;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Colors.blue.shade100;
      case 'inprogress':
        return Colors.orange.shade100;

      case 'done':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Future<void> _deleteDialog(BuildContext parentContext, String taskId) async {
    return showDialog(
      context: parentContext,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Are you sure you want to delete?",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("No", style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  parentContext.read<TaskCubit>().deleteTask(
                    // Use parentContext here
                    workspaceId: widget.workspaceId,
                    boardId: widget.boardId,
                    taskId: taskId,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Yes", style: TextStyle(fontSize: 18)),
              ),
            ],
            icon: const Icon(Icons.delete, size: 35, color: Colors.red),
          ),
    );
  }
}
