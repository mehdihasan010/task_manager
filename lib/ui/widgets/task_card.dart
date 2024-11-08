// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:task_manager/data/models/network_response.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utils/urls.dart';
import 'package:task_manager/ui/utils/app_colors.dart';
import 'package:task_manager/ui/widgets/snack_bar_message.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.taskModel,
    required this.updateWidget,
  });

  final TaskModel taskModel;
  final Function updateWidget;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isDeleting = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskModel.title ?? '',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.taskModel.description ?? '',
            ),
            Text(
              'Date: ${widget.taskModel.createdDate ?? ''}',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTaskStatusChip(),
                Wrap(
                  children: [
                    IconButton(
                      onPressed: _onTapEditButton,
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: _onTapDeleteButton,
                      icon: _isDeleting
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Icon(Icons.delete),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onTapEditButton() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['New', 'Completed', 'Cancelled', 'Progress'].map((e) {
              return ListTile(
                onTap: () {
                  print(e);
                  _updateTaskStatus('/$e');
                },
                title: Text(e),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void _onTapDeleteButton() {
    if (!_isDeleting) {
      _deleteTaskItem();
    }
  }

  Widget _buildTaskStatusChip() {
    return Chip(
      label: const Text(
        'New',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: const BorderSide(
        color: AppColors.themeColor,
      ),
    );
  }

  Future<void> _updateTaskStatus(String status) async {
    String url = Urls.updateTaskStatus + widget.taskModel.sId! + status;
    final NetworkResponse response = await NetworkCaller.getRequest(url: url);

    if (response.isSuccess) {
      widget.updateWidget();
      showSnackBarMessage(context, 'Edit successfull');
    } else {
      showSnackBarMessage(context, response.errorMessage);
    }
  }

  Future<void> _deleteTaskItem() async {
    setState(() {
      _isDeleting = true; // Show a loading indicator while deleting
    });

    final NetworkResponse response = await NetworkCaller.getRequest(
      url: Urls.deleteTask + widget.taskModel.sId!,
    );

    if (response.isSuccess) {
      widget.updateWidget();
      showSnackBarMessage(context, 'Delete Successful', false);
    } else {
      showSnackBarMessage(context, response.errorMessage, true);
    }

    setState(() {
      _isDeleting = false;
    });
  }
}
