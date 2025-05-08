import 'package:collabo/features/auth/widgets/customTextfield.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/di.dart';
import '../controller/workspace_cubit.dart';
import '../controller/workspace_states.dart';

class CreateWorkspaceScreen extends StatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  State<CreateWorkspaceScreen> createState() => _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends State<CreateWorkspaceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          'Create Workspace',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: BlocProvider(
        create: (context) => sl<WorkSpaceCubit>(),

        child: BlocConsumer<WorkSpaceCubit, WorkspaceStates>(
          listener: (context, state) {
            if (state is WorkspaceSuccessStates) {
              Fluttertoast.showToast(
                msg: 'Workspace created successfully',
                backgroundColor: Colors.green,
              );
              Navigator.pop(context); // Return to HomeScreen
            }
            if (state is WorkspaceErrorStates) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextFormField(
                        controller: nameController,
                        labelText: 'Workspace Name',
                        prefixIcon: Icons.drive_file_rename_outline,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
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

                      const SizedBox(height: 35),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 40,
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<WorkSpaceCubit>().createWorkSpace(
                              nameController.text,
                              descriptionController.text,
                              generateShortId(8),
                            );
                          }
                        },
                        child: ConditionalBuilder(
                          condition: state is! WorkspaceLoadingStates,
                          builder: (context) => const Text('Create Workspace'),
                          fallback:
                              (context) => const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
