import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.login,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your phone number to continue',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: AppStrings.phoneNumber,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: AppStrings.continueText,
                onPressed: () => context.go(AppRoutes.chats),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text(AppStrings.dontHaveAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
