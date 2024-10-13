import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget{
  final VoidCallback onTap;
  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.delete,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}