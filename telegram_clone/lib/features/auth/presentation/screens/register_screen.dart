import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.login)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.register,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: AppStrings.username,
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: AppStrings.phoneNumber,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: AppStrings.password,
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: AppStrings.register,
                onPressed: () => context.go(AppRoutes.chats),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(AppStrings.alreadyHaveAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
