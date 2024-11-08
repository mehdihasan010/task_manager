import 'package:flutter/material.dart';

class NoTaskMassage extends StatelessWidget {
  const NoTaskMassage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'There are no tasks to show',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Tap the add button to add some',
        ),
      ],
    ));
  }
}
