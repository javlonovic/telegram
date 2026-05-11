import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:telegram_clone/core/router/app_routes.dart';

/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8**
///
/// **Property 1: Fault Condition** - Navigation with Absolute Paths Breaks Stack
///
/// **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
/// **DO NOT attempt to fix the test or the code when it fails**
/// **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
/// **GOAL**: Surface counterexamples that demonstrate the bug exists
///
/// This test verifies that navigation using absolute paths with context.push() breaks
/// the navigation stack, causing back navigation to fail (black screen).
///
/// Test scenarios:
/// 1. ChatsScreen → ProfileScreen using absolute path '/chats/profile'
/// 2. ChatsScreen → SettingsScreen using absolute path '/chats/settings'
/// 3. ProfileScreen → EditProfileScreen using absolute path '/chats/profile/edit'
/// 4. Verify back button after broken navigation shows black screen or fails
void main() {
  group('Bug Condition Exploration - Navigation Stack Breaks with Absolute Paths', () {
    late GoRouter router;

    setUp(() {
      // Create a test router with the same structure as the app
      router = GoRouter(
        initialLocation: '/chats',
        routes: [
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Chats Screen')),
              body: const Center(child: Text('Chats Screen')),
            ),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Profile Screen')),
                  body: const Center(child: Text('Profile Screen')),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit-profile',
                    builder: (context, state) => Scaffold(
                      appBar: AppBar(title: const Text('Edit Profile Screen')),
                      body: const Center(child: Text('Edit Profile Screen')),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Settings Screen')),
                  body: const Center(child: Text('Settings Screen')),
                ),
              ),
            ],
          ),
        ],
      );
    });

    /// Test 1.1: ChatsScreen → ProfileScreen using absolute path breaks stack
    /// **Validates: Requirement 1.1**
    testWidgets(
      'FAULT: Navigating from ChatsScreen to ProfileScreen with absolute path /chats/profile breaks navigation stack',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Verify we're on ChatsScreen
        expect(find.text('Chats Screen'), findsOneWidget);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/chats');

        // Navigate to ProfileScreen using ABSOLUTE path (this is the bug)
        router.push(AppRoutes.profile); // AppRoutes.profile = '/chats/profile'
        await tester.pumpAndSettle();

        // Verify we're on ProfileScreen
        expect(find.text('Profile Screen'), findsOneWidget);
        
        // Check the navigation stack - with absolute paths, the stack is broken
        final location = router.routerDelegate.currentConfiguration.uri.path;
        expect(location, '/chats/profile');

        // Try to go back - this should work correctly but will fail with absolute paths
        // The bug manifests as either:
        // 1. canPop() returns false when it should return true
        // 2. pop() causes a black screen
        // 3. The navigation stack is corrupted
        
        final canGoBack = router.canPop();
        
        // EXPECTED BEHAVIOR: Should be able to pop back to ChatsScreen
        // ACTUAL BEHAVIOR (BUG): canPop() may return false or pop() shows black screen
        expect(
          canGoBack,
          isTrue,
          reason: 'Should be able to navigate back to ChatsScreen, but absolute path breaks stack',
        );

        if (canGoBack) {
          router.pop();
          await tester.pumpAndSettle();

          // EXPECTED: Should be back on ChatsScreen
          // ACTUAL (BUG): May show black screen or wrong screen
          expect(
            find.text('Chats Screen'),
            findsOneWidget,
            reason: 'Back navigation should return to ChatsScreen, not black screen',
          );
        }
      },
    );

    /// Test 1.2: ChatsScreen → SettingsScreen using absolute path breaks stack
    /// **Validates: Requirement 1.2**
    testWidgets(
      'FAULT: Navigating from ChatsScreen to SettingsScreen with absolute path /chats/settings breaks navigation stack',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Verify we're on ChatsScreen
        expect(find.text('Chats Screen'), findsOneWidget);

        // Navigate to SettingsScreen using ABSOLUTE path (this is the bug)
        router.push(AppRoutes.settings); // AppRoutes.settings = '/chats/settings'
        await tester.pumpAndSettle();

        // Verify we're on SettingsScreen
        expect(find.text('Settings Screen'), findsOneWidget);

        // Try to go back
        final canGoBack = router.canPop();
        
        expect(
          canGoBack,
          isTrue,
          reason: 'Should be able to navigate back to ChatsScreen',
        );

        if (canGoBack) {
          router.pop();
          await tester.pumpAndSettle();

          expect(
            find.text('Chats Screen'),
            findsOneWidget,
            reason: 'Back navigation should return to ChatsScreen',
          );
        }
      },
    );

    /// Test 1.6: ProfileScreen → EditProfileScreen using absolute path breaks stack
    /// **Validates: Requirement 1.6**
    testWidgets(
      'FAULT: Navigating from ProfileScreen to EditProfileScreen with absolute path /chats/profile/edit breaks navigation stack',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ProfileScreen first (using absolute path - simulating current bug)
        router.push(AppRoutes.profile);
        await tester.pumpAndSettle();
        expect(find.text('Profile Screen'), findsOneWidget);

        // Now navigate to EditProfileScreen using ABSOLUTE path (this is the bug)
        router.push(AppRoutes.editProfile); // AppRoutes.editProfile = '/chats/profile/edit'
        await tester.pumpAndSettle();

        // Verify we're on EditProfileScreen
        expect(find.text('Edit Profile Screen'), findsOneWidget);

        // Try to go back to ProfileScreen
        final canGoBack = router.canPop();
        
        expect(
          canGoBack,
          isTrue,
          reason: 'Should be able to navigate back to ProfileScreen',
        );

        if (canGoBack) {
          router.pop();
          await tester.pumpAndSettle();

          expect(
            find.text('Profile Screen'),
            findsOneWidget,
            reason: 'Back navigation should return to ProfileScreen',
          );
          
          // Try to go back again to ChatsScreen
          final canGoBackAgain = router.canPop();
          expect(
            canGoBackAgain,
            isTrue,
            reason: 'Should be able to navigate back to ChatsScreen',
          );

          if (canGoBackAgain) {
            router.pop();
            await tester.pumpAndSettle();

            expect(
              find.text('Chats Screen'),
              findsOneWidget,
              reason: 'Second back navigation should return to ChatsScreen',
            );
          }
        }
      },
    );

    /// Test 1.8: Multiple navigation paths and back button behavior
    /// **Validates: Requirement 1.8**
    testWidgets(
      'FAULT: Back button after broken navigation shows black screen or navigation failure',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Start at ChatsScreen
        expect(find.text('Chats Screen'), findsOneWidget);
        final initialStackDepth = router.routerDelegate.currentConfiguration.matches.length;

        // Navigate through multiple screens using absolute paths
        router.push(AppRoutes.profile);
        await tester.pumpAndSettle();
        
        router.push(AppRoutes.editProfile);
        await tester.pumpAndSettle();

        // Check stack depth - with absolute paths, stack may not grow correctly
        final currentStackDepth = router.routerDelegate.currentConfiguration.matches.length;
        
        // EXPECTED: Stack should have grown by 2 (ChatsScreen -> ProfileScreen -> EditProfileScreen)
        // ACTUAL (BUG): Stack may not grow correctly with absolute paths
        expect(
          currentStackDepth,
          greaterThan(initialStackDepth),
          reason: 'Navigation stack should grow with each push',
        );

        // Try to navigate back through the stack
        var backNavigationSuccessful = true;
        var navigationSteps = 0;

        while (router.canPop() && navigationSteps < 5) {
          router.pop();
          await tester.pumpAndSettle();
          navigationSteps++;

          // Check if we hit a black screen (no widgets found)
          final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
          if (!hasContent) {
            backNavigationSuccessful = false;
            break;
          }
        }

        expect(
          backNavigationSuccessful,
          isTrue,
          reason: 'Back navigation should not result in black screen',
        );

        expect(
          find.text('Chats Screen'),
          findsOneWidget,
          reason: 'Should eventually return to ChatsScreen',
        );
      },
    );
  });
}
