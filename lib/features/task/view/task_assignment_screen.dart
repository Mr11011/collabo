import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../controller/task_cubit.dart';
import '../controller/task_states.dart';

class TaskAssignmentScreen extends StatefulWidget {
  final String workspaceId;
  final String boardId;
  final String taskId;
  final List<String> currentAssignees;
  final DateTime? currentDueDate;

  const TaskAssignmentScreen({
    super.key,
    required this.workspaceId,
    required this.boardId,
    required this.taskId,
    required this.currentAssignees,
    this.currentDueDate,
  });

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  List<String> selectedAssignees = [];
  DateTime? selectedDueDate;
  List<Map<String, String>> members = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedAssignees = List.from(widget.currentAssignees);
    selectedDueDate = widget.currentDueDate;
    _fetchWorkspaceMembers();
  }

  Future<void> _fetchWorkspaceMembers() async {
    final workspace =
        await FirebaseFirestore.instance
            .collection('workspaces')
            .doc(widget.workspaceId)
            .get();
    final memberIds = List<String>.from(workspace.data()!['memberIds']);
    final fetchedMembers = <Map<String, String>>[];
    for (final uid in memberIds) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      fetchedMembers.add({'uid': uid, 'username': userDoc.data()!['username']});
    }
    setState(() {
      members = fetchedMembers;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  void _clearDueDate() {
    setState(() {
      selectedDueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shadowColor: Colors.grey,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20.0),
                child: BlocConsumer<TaskCubit, TaskStates>(
                  listener: (context, state) {
                    if (state is TaskUpdatedState) {
                      Fluttertoast.showToast(
                        msg: 'Task updated successfully',
                        backgroundColor: Colors.green,
                      );
                      Navigator.pop(context);
                    } else if (state is TaskErrorState) {
                      Fluttertoast.showToast(
                        msg: state.message,
                        backgroundColor: Colors.red,
                      );
                    }
                    setState(() {
                      isLoading = state is TaskLoadingState;
                    });
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assignees',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children:
                              members.map((member) {
                                final isSelected = selectedAssignees.contains(
                                  member['uid'],
                                );
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: ChoiceChip(
                                    checkmarkColor:
                                        isSelected ? Colors.white : Colors.grey,
                                    label: Text(
                                      member['username']!.replaceFirst(
                                        member['username']![0],
                                        member['username']![0].toUpperCase(),
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: Colors.deepPurpleAccent,
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedAssignees.add(member['uid']!);
                                        } else {
                                          selectedAssignees.remove(
                                            member['uid']!,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Due Date',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _selectDate,
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                label: Text(
                                  selectedDueDate != null
                                      ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(selectedDueDate!)
                                      : 'Pick Due Date',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if (selectedDueDate != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _clearDueDate,
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                tooltip: 'Clear Due Date',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed:
                              selectedAssignees.isEmpty
                                  ? null
                                  : () {
                                    context.read<TaskCubit>().updateTask(
                                      workspaceId: widget.workspaceId,
                                      boardId: widget.boardId,
                                      taskId: widget.taskId,
                                      assignedUserIds: selectedAssignees,
                                      dueDate: selectedDueDate,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
