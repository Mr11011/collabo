import 'package:collabo/features/task/controller/task_cubit.dart';
import 'package:collabo/features/task/controller/task_states.dart';
import 'package:collabo/features/task/data/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../core/di.dart';

class GanttChartScreen extends StatelessWidget {
  final String workspaceId;
  final String boardId;
  final String boardName;

  const GanttChartScreen({
    super.key,
    required this.workspaceId,
    required this.boardId,
    required this.boardName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$boardName Timeline'),
        backgroundColor: Colors.green.shade300,
      ),
      body: BlocProvider(
        create:
            (context) => sl<TaskCubit>()..listenToTasks(workspaceId, boardId),
        child: BlocBuilder<TaskCubit, TaskStates>(
          builder: (context, state) {
            if (state is TaskLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskErrorState) {
              return Center(child: Text(state.message));
            } else if (state is TaskSuccessState) {
              return _GanttView(tasks: state.tasks);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _GanttView extends StatelessWidget {
  final List<Task> tasks;
  final double dayWidth = 20.0;
  final double rowHeight = 36.0;

  const _GanttView({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks to display'));
    }

    final dateRange = _calculateDateRange(tasks);
    final totalDays =
        dateRange['end']!.difference(dateRange['start']!).inDays + 1;

    return Column(
      children: [
        // Month headers
        _buildMonthHeader(dateRange['start']!, dateRange['end']!),
        // Timeline view
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalDays * dayWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day indicators
                  _buildDayIndicator(dateRange['start']!, totalDays),
                  // Tasks
                  ...tasks.map(
                    (task) => _buildTaskBar(task, dateRange['start']!),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, DateTime> _calculateDateRange(List<Task> tasks) {
    final startDate = tasks
        .map((task) => task.createdAt.toDate())
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .subtract(const Duration(days: 1));

    final endDate = tasks
        .map(
          (task) =>
              task.dueDate?.toDate() ??
              task.createdAt.toDate().add(const Duration(days: 2)),
        )
        .reduce((a, b) => a.isAfter(b) ? a : b)
        .add(const Duration(days: 3));

    return {'start': startDate, 'end': endDate};
  }

  Widget _buildMonthHeader(DateTime startDate, DateTime endDate) {
    final months = <DateTime>[];
    DateTime current = DateTime(startDate.year, startDate.month);

    while (current.isBefore(endDate)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }

    return SizedBox(
      height: 24,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
          final width = daysInMonth * dayWidth;

          return Container(
            width: width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              DateFormat('MMM yyyy').format(month),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayIndicator(DateTime startDate, int totalDays) {
    return SizedBox(
      height: 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          return SizedBox(
            width: dayWidth,
            child: Center(
              child: Text(
                DateFormat('d').format(date),
                style: TextStyle(
                  fontSize: 10,
                  color:
                      date.weekday == 6 || date.weekday == 7
                          ? Colors.red.shade300
                          : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskBar(Task task, DateTime timelineStart) {
    final startDate = task.createdAt.toDate();
    final endDate =
        task.dueDate?.toDate() ?? startDate.add(const Duration(days: 1));
    final startOffset = startDate.difference(timelineStart).inDays;
    final durationDays = endDate.difference(startDate).inDays + 1;

    Color getStatusColor() {
      switch (task.status) {
        case 'todo':
          return Colors.grey.shade400;
        case 'inProgress':
          return Colors.orange.shade400;
        case 'done':
          return Colors.green.shade400;
        default:
          return Colors.blue.shade400;
      }
    }

    return Container(
      height: rowHeight,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          Positioned(
            left: startOffset * dayWidth,
            width: durationDays * dayWidth,
            child: Container(
              height: rowHeight,
              decoration: BoxDecoration(
                color: getStatusColor().withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
