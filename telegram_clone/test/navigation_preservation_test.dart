import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:telegram_clone/core/router/app_routes.dart';

/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
///
/// **Property 2: Preservation** - Top-Level Navigation and Auth Redirects
///
/// **IMPORTANT**: Follow observation-first methodology
/// These tests verify behaviors that should NOT change during the fix.
/// They should PASS on the current unfixed code to establish baseline behavior.
///
/// Test scenarios:
/// 1. context.go() for top-level navigation (login → chats) works correctly
/// 2. context.pop() works when navigation stack is valid
/// 3. context.go(AppRoutes.chats) fallback works when canPop() returns false
/// 4. Authentication redirects using context.go() work correctly
/// 5. Route parameters (chatId) are passed and received correctly
/// 6. Custom page transitions (fade, slide) display correctly
void main() {
  group('Preservation Tests - Behaviors That Must Not Change', () {
    late GoRouter router;

    setUp(() {
      // Create a test router with the same structure as the app
      router = GoRouter(
        initialLocation: '/login',
        routes: [
          // Public routes
          GoRoute(
            path: '/login',
            name: 'login',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                appBar: AppBar(title: const Text('Login Screen')),
                body: const Center(child: Text('Login Screen')),
              ),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                appBar: AppBar(title: const Text('Register Screen')),
                body: const Center(child: Text('Register Screen')),
              ),
              transitionsBuilder: _slideTransition,
            ),
          ),
          // Authenticated routes
          GoRoute(
            path: '/chats',
            name: 'chats',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                appBar: AppBar(title: const Text('Chats Screen')),
                body: const Center(child: Text('Chats Screen')),
              ),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: ':chatId',
                name: 'chat',
                pageBuilder: (context, state) {
                  final chatId = state.pathParameters['chatId']!;
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: Scaffold(
                      appBar: AppBar(title: Text('Chat $chatId')),
                      body: Center(child: Text('Chat Screen: $chatId')),
                    ),
                    transitionsBuilder: _slideTransition,
                  );
                },
              ),
              GoRoute(
                path: 'profile',
                name: 'profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Profile Screen')),
                    body: const Center(child: Text('Profile Screen')),
                  ),
                  transitionsBuilder: _slideTransition,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit-profile',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: Scaffold(
                        appBar: AppBar(title: const Text('Edit Profile Screen')),
                        body: const Center(child: Text('Edit Profile Screen')),
                      ),
                      transitionsBuilder: _slideTransition,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });

    /// Test 3.1: context.go() for top-level navigation works correctly
    /// **Validates: Requirement 3.1**
    testWidgets(
      'PRESERVE: context.go() for top-level navigation (login → chats) uses absolute paths correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Verify we're on LoginScreen
        expect(find.text('Login Screen'), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

        // Navigate to ChatsScreen using context.go() with absolute path
        // This is CORRECT for top-level navigation (replacing the entire stack)
        router.go(AppRoutes.chats); // AppRoutes.chats = '/chats'
        await tester.pumpAndSettle();

        // Verify we're on ChatsScreen
        expect(find.text('Chats Screen'), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/chats');

        // Verify the navigation stack was replaced (not pushed)
        // canPop() should return false because we replaced the stack
        final canGoBack = router.canPop();
        expect(
          canGoBack,
          isFalse,
          reason: 'context.go() should replace the stack, not push onto it',
        );
      },
    );

    /// Test 3.2: context.go() fallback when canPop() returns false
    /// **Validates: Requirement 3.2**
    testWidgets(
      'PRESERVE: context.go(AppRoutes.chats) fallback works when canPop() returns false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ChatsScreen (replacing stack)
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();

        expect(find.text('Chats Screen'), findsWidgets);

        // Verify canPop() returns false (we're at the root)
        final canGoBack = router.canPop();
        expect(canGoBack, isFalse, reason: 'Should be at root of navigation stack');

        // Simulate a back button handler that uses context.go() as fallback
        if (!router.canPop()) {
          // This is the fallback pattern used in the app
          router.go(AppRoutes.chats);
          await tester.pumpAndSettle();
        }

        // Verify we're still on ChatsScreen (fallback worked)
        expect(find.text('Chats Screen'), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/chats');
      },
    );

    /// Test 3.3: context.pop() works when navigation stack is valid
    /// **Validates: Requirement 3.3**
    testWidgets(
      'PRESERVE: context.pop() works correctly with valid navigation stack',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Start at LoginScreen
        expect(find.text('Login Screen'), findsWidgets);

        // Navigate to ChatsScreen
        router.go('/chats');
        await tester.pumpAndSettle();
        expect(find.text('Chats Screen'), findsWidgets);

        // Navigate to RegisterScreen (building a stack)
        router.push('/register');
        await tester.pumpAndSettle();
        expect(find.text('Register Screen'), findsWidgets);

        // Verify we can pop
        final canGoBack = router.canPop();
        expect(canGoBack, isTrue, reason: 'Should be able to pop back');

        // Pop back
        router.pop();
        await tester.pumpAndSettle();

        // Verify pop worked (we should be somewhere, not on a black screen)
        expect(find.byType(Scaffold), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, isNotEmpty);
      },
    );

    /// Test 3.4: Authentication redirects using context.go() work correctly
    /// **Validates: Requirement 3.4**
    testWidgets(
      'PRESERVE: Authentication redirects using context.go() with full paths work correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Start at LoginScreen
        expect(find.text('Login Screen'), findsWidgets);

        // Simulate successful login - redirect to ChatsScreen using context.go()
        // This is CORRECT for authentication redirects (replacing the stack)
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();

        expect(find.text('Chats Screen'), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/chats');

        // Verify the stack was replaced (can't go back to login)
        expect(router.canPop(), isFalse, reason: 'Should not be able to go back to login after auth redirect');

        // Simulate logout - redirect back to LoginScreen using context.go()
        router.go(AppRoutes.login);
        await tester.pumpAndSettle();

        expect(find.text('Login Screen'), findsWidgets);
        expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

        // Verify the stack was replaced (can't go back to chats)
        expect(router.canPop(), isFalse, reason: 'Should not be able to go back to chats after logout');
      },
    );

    /// Test 3.5: Custom page transitions display correctly
    /// **Validates: Requirement 3.5**
    testWidgets(
      'PRESERVE: Custom page transitions (fade, slide) display correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ChatsScreen (uses fade transition)
        router.go(AppRoutes.chats);
        await tester.pump(); // Start transition
        await tester.pump(const Duration(milliseconds: 100)); // Advance animation
        
        // Verify screen is present during transition
        expect(find.byType(Scaffold), findsWidgets);
        
        await tester.pumpAndSettle(); // Complete transition
        expect(find.text('Chats Screen'), findsWidgets);

        // Navigate to ProfileScreen using context.go() (uses slide transition)
        router.go(AppRoutes.profile);
        await tester.pump(); // Start transition
        await tester.pump(const Duration(milliseconds: 100)); // Advance animation
        
        // Verify screen is present during transition
        expect(find.byType(Scaffold), findsWidgets);
        
        await tester.pumpAndSettle(); // Complete transition
        expect(find.text('Profile Screen'), findsWidgets);

        // Navigate to RegisterScreen from LoginScreen (uses slide transition)
        router.go(AppRoutes.login);
        await tester.pumpAndSettle();
        
        router.push(AppRoutes.register);
        await tester.pump(); // Start transition
        await tester.pump(const Duration(milliseconds: 100)); // Advance animation
        
        expect(find.byType(Scaffold), findsWidgets);
        
        await tester.pumpAndSettle(); // Complete transition
        expect(find.text('Register Screen'), findsWidgets);
      },
    );

    /// Test 3.6: Route parameters are passed and received correctly
    /// **Validates: Requirement 3.6**
    testWidgets(
      'PRESERVE: Route parameters (chatId) are passed and received correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ChatsScreen
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();
        expect(find.text('Chats Screen'), findsWidgets);

        // Navigate to a specific chat using context.go() with full path
        const testChatId = '12345';
        router.go('/chats/$testChatId');
        await tester.pumpAndSettle();

        // Verify we're on ChatScreen with correct chatId
        expect(find.text('Chat $testChatId'), findsWidgets);
        expect(find.text('Chat Screen: $testChatId'), findsWidgets);
        
        // Verify the route path includes the chatId
        final currentPath = router.routerDelegate.currentConfiguration.uri.path;
        expect(currentPath, '/chats/$testChatId');

        // Navigate to another chat using context.go()
        const anotherChatId = '67890';
        router.go('/chats/$anotherChatId');
        await tester.pumpAndSettle();

        // Verify the new chatId is received correctly
        expect(find.text('Chat $anotherChatId'), findsWidgets);
        expect(find.text('Chat Screen: $anotherChatId'), findsWidgets);
        
        final newPath = router.routerDelegate.currentConfiguration.uri.path;
        expect(newPath, '/chats/$anotherChatId');
      },
    );

    /// Combined test: Multiple preservation behaviors work together
    /// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
    testWidgets(
      'PRESERVE: All preservation behaviors work correctly together',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Start at login (simulating app start)
        expect(find.text('Login Screen'), findsWidgets);

        // 2. Auth redirect to chats using context.go() (Req 3.1, 3.4)
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();
        expect(find.text('Chats Screen'), findsWidgets);
        expect(router.canPop(), isFalse, reason: 'Auth redirect should replace stack');

        // 3. Navigate to profile using context.go() (current app behavior)
        router.go(AppRoutes.profile);
        await tester.pumpAndSettle();
        expect(find.text('Profile Screen'), findsWidgets);

        // 4. Navigate to edit profile using context.go()
        router.go(AppRoutes.editProfile);
        await tester.pumpAndSettle();
        expect(find.text('Edit Profile Screen'), findsWidgets);

        // 5. Test context.pop() functionality (Req 3.3)
        // Note: Due to the bug, the stack might be broken, but we test that pop() works
        if (router.canPop()) {
          router.pop();
          await tester.pumpAndSettle();
          // Verify pop executed without error
          expect(router.routerDelegate.currentConfiguration.uri.path, isNotEmpty);
        }

        // 6. Go back to chats using context.go()
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();
        expect(find.text('Chats Screen'), findsWidgets);

        // 7. Navigate to chat with parameter using context.go() (Req 3.6)
        const chatId = '99999';
        router.go('/chats/$chatId');
        await tester.pumpAndSettle();
        expect(find.text('Chat Screen: $chatId'), findsWidgets);

        // 8. Go back to chats using context.go()
        router.go(AppRoutes.chats);
        await tester.pumpAndSettle();
        expect(find.text('Chats Screen'), findsWidgets);

        // 9. Try to pop when at root - should use fallback (Req 3.2)
        expect(router.canPop(), isFalse);
        if (!router.canPop()) {
          router.go(AppRoutes.chats);
          await tester.pumpAndSettle();
        }
        expect(find.text('Chats Screen'), findsWidgets);
      },
    );
  });
}

// Helper functions for custom transitions
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}
