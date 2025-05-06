import 'package:collabo/features/auth/views/sign_in_screen.dart';
import 'package:collabo/features/auth/widgets/customTextfield.dart';
import 'package:collabo/features/workspace/controller/workspace_cubit.dart';
import 'package:collabo/features/workspace/controller/workspace_states.dart';
import 'package:collabo/features/workspace/views/create_workspaces_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../core/di.dart';
import 'auth/controller/auth_cubit.dart';
import 'auth/controller/auth_states.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Colors.grey.shade300,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              sl<AuthCubit>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),

      body: BlocBuilder<AuthCubit, AuthStates>(
        builder: (context, authState) {
          if (authState is AuthSuccessState) {
            // Fetch workspaces when AuthSuccessState is confirmed
            context.read<WorkSpaceCubit>().fetchWorkspaces();
            return BlocBuilder<WorkSpaceCubit, WorkspaceStates>(
              builder: (context, workspaceState) {
                if (workspaceState is WorkspaceLoadingStates) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (workspaceState is WorkspaceFailedJoiningStates) {
                  Fluttertoast.showToast(
                    msg: workspaceState.message,
                    backgroundColor: Colors.red,
                  );
                  context.read<WorkSpaceCubit>().fetchWorkspaces();

                }
                if (workspaceState is WorkspaceErrorStates) {
                  return Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 35,
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const JoinWorkspaceDialog(),
                              ).then((_) {
                                // Refresh workspaces after returning
                                context
                                    .read<WorkSpaceCubit>()
                                    .fetchWorkspaces();
                              });
                            },
                            icon: const Icon(Icons.groups, size: 25),
                            label: const Text("Join Workspace"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade300,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              context.read<WorkSpaceCubit>().fetchWorkspaces();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              workspaceState.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () {
                    return context.read<WorkSpaceCubit>().fetchWorkspaces();
                  },
                  child: Column(
                    children: [
                      // Header with greeting and create button
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello, 👋',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  authState.userData.username.replaceFirst(
                                    authState.userData.username[0],
                                    authState.userData.username[0]
                                        .toUpperCase(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CreateWorkspaceScreen(),
                                  ),
                                ).then((_) {
                                  // Refresh workspaces after returning
                                  context
                                      .read<WorkSpaceCubit>()
                                      .fetchWorkspaces();
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add Workspace"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const JoinWorkspaceDialog(),
                            ).then((_) {
                              // Refresh workspaces after returning
                              context.read<WorkSpaceCubit>().fetchWorkspaces();
                            });
                          },
                          icon: const Icon(Icons.groups, size: 25),
                          label: const Text("Join Workspace"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade300,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Grid of workspaces
                      Expanded(
                        child:
                            workspaceState is WorkspaceSuccessStates
                                ? workspaceState.workSpaceData.isEmpty
                                    ? const Center(
                                      child: Text(
                                        "No workspaces found. Create one!",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                    : GridView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.60,
                                          ),
                                      itemCount:
                                          workspaceState.workSpaceData.length,
                                      itemBuilder: (context, index) {
                                        final workspace =
                                            workspaceState.workSpaceData[index];
                                        final createdDate = DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(workspace.createdAt.toDate());
                                        return Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Navigate to workspace details or Kanban screen
                                            },
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    workspace.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    workspace.description,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const Spacer(),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "ID: ${workspace.workspaceId}",
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          const Text(
                                                            'Created',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        createdDate,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.group,
                                                        size: 16,
                                                        color: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${workspace.memberIds.length} Member${workspace.memberIds.length != 1 ? 's' : ''}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                : workspaceState is WorkspaceErrorStates
                                ? Center(
                                  child: Text(
                                    workspaceState.message,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                                : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Loading"));
        },
      ),
    );
  }
}

class JoinWorkspaceDialog extends StatefulWidget {
  const JoinWorkspaceDialog({super.key});

  @override
  State<JoinWorkspaceDialog> createState() => _JoinWorkspaceDialogState();
}

class _JoinWorkspaceDialogState extends State<JoinWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _workspaceIdController = TextEditingController();

  @override
  void dispose() {
    _workspaceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Join Workspace',
        style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: CustomTextFormField(
          controller: _workspaceIdController,
          labelText: 'Workspace ID',
          hintText: 'Enter the workspace ID',
          validator:
              (value) => value?.isEmpty ?? true ? 'ID is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<WorkSpaceCubit>().joinWorkspace(
                _workspaceIdController.text.trim(),
              );
              _workspaceIdController.clear();
              Navigator.pop(context);
            }
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}
