import 'package:flutter/material.dart';
import 'package:task_manager/data/models/network_response.dart';
import 'package:task_manager/data/models/task_list_model.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utils/urls.dart';
import 'package:task_manager/ui/screens/add_new_task_screen.dart';
import 'package:task_manager/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager/ui/widgets/no_task_massage.dart';
import 'package:task_manager/ui/widgets/snack_bar_message.dart';
import 'package:task_manager/ui/widgets/task_card.dart';
import 'package:task_manager/ui/widgets/task_summary_card.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  bool _getNewTaskListInProgress = false;
  List<TaskModel> _newTaskList = [];
  // ignore: prefer_final_fields
  List<int> _summaryTaskList = [];
  final List<String> _urlList = [
    Urls.newTaskList,
    Urls.completedTaskList,
    Urls.cancelledTaskList,
    Urls.progressTaskList
  ];

  @override
  void initState() {
    super.initState();
    _getNewTaskList();
    _getSummaryTaskList();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _getNewTaskList();
        },
        child: Visibility(
          visible: !_getNewTaskListInProgress,
          replacement: const CenteredCircularProgressIndicator(),
          child: Visibility(
            visible: _newTaskList.isNotEmpty,
            replacement: const NoTaskMassage(),
            child: Column(
              children: [
                _buildSummarySection(),
                Expanded(
                  child: ListView.separated(
                    itemCount: _newTaskList.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        taskModel: _newTaskList[index],
                        updateWidget: () {
                          _getNewTaskList();
                          _getSummaryTaskList();
                          setState(() {});
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 8);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddFAB,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['New', 'Completed', 'Cancelled', 'Progress']
                .asMap()
                .entries
                .map((entry) {
              int index = entry.key; // Access the index
              String title =
                  entry.value; // Access the title (New, Completed, etc.)
              return TaskSummaryCard(
                count: _summaryTaskList.isNotEmpty &&
                        index < _summaryTaskList.length
                    ? _summaryTaskList[index] // Access count based on index
                    : 0, // Default to 0 if the list is empty or the index is out of bounds
                title: title, // The title (New, Completed, Cancelled, etc.)
              );
            }).toList(),
          )),
    );
  }

  Future<void> _onTapAddFAB() async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewTaskScreen(),
      ),
    );
    if (shouldRefresh == true) {
      _getNewTaskList();
      _getSummaryTaskList();
    }
  }

  Future<void> _getNewTaskList() async {
    _newTaskList.clear();
    _getNewTaskListInProgress = true;
    setState(() {});
    final NetworkResponse response =
        await NetworkCaller.getRequest(url: Urls.newTaskList);
    if (response.isSuccess) {
      final TaskListModel taskListModel =
          TaskListModel.fromJson(response.responseData);
      _newTaskList = taskListModel.taskList ?? [];
    } else {
      if (mounted) showSnackBarMessage(context, response.errorMessage, true);
    }
    _getNewTaskListInProgress = false;
    setState(() {});
  }

  Future<void> _getSummaryTaskList() async {
    if (!mounted) return;
    _summaryTaskList.clear(); // Clear summary list before fetching new data
    _getNewTaskListInProgress = true;
    setState(() {}); // Trigger UI refresh for progress indicator

    for (String item in _urlList) {
      final NetworkResponse response =
          await NetworkCaller.getRequest(url: item);

      if (response.isSuccess) {
        final TaskListModel taskListModel =
            TaskListModel.fromJson(response.responseData);

        _summaryTaskList.add(taskListModel.taskList?.length ?? 0);
      } else {
        // If there's an error, handle it as appropriate
        // ignore: use_build_context_synchronously
        if (mounted) {
          showSnackBarMessage(context, response.errorMessage, true);
        }
      }
    }

    _getNewTaskListInProgress = false;
    setState(() {});
    // Trigger UI update to reflect the changes in _summaryTaskList
  }
}
