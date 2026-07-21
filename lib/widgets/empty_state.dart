import 'package:flutter/material.dart';
import '../core/theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24), // Tambahin horizontal padding biar gak mentok pinggir
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      alignment: Alignment.center,
      child: Text(
        message, 
        textAlign: TextAlign.center, // <--- INI BIAR TEKSNYA RATA TENGAH
        style: TextStyle(
          color: AppColors.mutedDim(context), 
          fontSize: 14
        ),
      ),
    );
  }
}