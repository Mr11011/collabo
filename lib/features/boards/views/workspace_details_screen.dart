import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../auth/widgets/customTextfield.dart';
import '../../task/view/board_details_screen.dart';
import '../controller/board_cubit.dart';
import '../controller/board_states.dart';
import '../../../core/di.dart';

class WorkspaceDetailsScreen extends StatefulWidget {
  final String workspaceId;
  final String workspaceName;
  final String workspaceDescription;
  final int memberCount;

  const WorkspaceDetailsScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
    required this.workspaceDescription,
    required this.memberCount,
  });

  @override
  State<WorkspaceDetailsScreen> createState() => _WorkspaceDetailsScreenState();
}

class _WorkspaceDetailsScreenState extends State<WorkspaceDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isFormVisible = false;

  void _toggleForm() {
    setState(() {
      _isFormVisible = !_isFormVisible;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WorkSpace"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleForm,
        backgroundColor: Colors.green.shade300,
        child: Icon(
          _isFormVisible ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
      body: BlocProvider(
        create: (context) => sl<BoardCubit>()..fetchBoards(widget.workspaceId),
        child: BlocConsumer<BoardCubit, BoardStates>(
          listener: (context, state) {
            if (state is BoardCreatedState) {
              Fluttertoast.showToast(
                msg: 'Board created successfully',
                backgroundColor: Colors.green,
              );
              nameController.clear();
              descriptionController.clear();
              _toggleForm();
            } else if (state is BoardErrorState) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.redAccent,
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: [
                    // Workspace Details Header
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workspaceName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.workspaceDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.memberCount} Member${widget.memberCount != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (state is BoardSuccessState)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Boards",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    // Boards List
                    Expanded(
                      child:
                          state is BoardLoadingState
                              ? const Center(child: CircularProgressIndicator())
                              : state is BoardSuccessState
                              ? state.boards.isEmpty
                                  ? const Center(
                                    child: Text('No boards found. Create one!'),
                                  )
                                  : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: state.boards.length,
                                    itemBuilder: (context, index) {
                                      final board = state.boards[index];
                                      final createdDate = DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(board.createdAt.toDate());
                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            board.boardName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(board.boardDescription),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Created: $createdDate',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => BoardDetailsScreen(
                                                      workspaceId:
                                                          widget.workspaceId,
                                                      boardId: board.boardId,
                                                      boardName:
                                                          board.boardName,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                              : state is BoardErrorState
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
                // Animated Form Overlay
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
                                    'Create New Board',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextFormField(
                                    controller: nameController,
                                    labelText: 'Board Name',
                                    prefixIcon: Icons.dashboard,
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? 'Name is required'
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
                                                  .read<BoardCubit>()
                                                  .createBoard(
                                                    widget.workspaceId,
                                                    nameController.text.trim(),
                                                    descriptionController.text
                                                        .trim(),
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
}
