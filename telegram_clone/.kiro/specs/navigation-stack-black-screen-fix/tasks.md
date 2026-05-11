# Implementation Plan

- [x] 1. Write bug condition exploration test
  - **Property 1: Fault Condition** - Navigation with Absolute Paths Breaks Stack
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Test concrete navigation scenarios that trigger the bug
  - Test that navigating from ChatsScreen to ProfileScreen using `context.push('/chats/profile')` breaks the navigation stack
  - Test that pressing back after such navigation results in a black screen or navigation failure
  - Test multiple navigation paths: ChatsScreen → ProfileScreen, ChatsScreen → SettingsScreen, ProfileScreen → EditProfileScreen
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found to understand root cause
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8_

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Top-Level Navigation and Auth Redirects
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy navigation patterns
  - Test that `context.go()` navigation for top-level routes (login → chats) works correctly
  - Test that `context.pop()` works when navigation stack is valid
  - Test that `context.go(AppRoutes.chats)` fallback works when `context.canPop()` returns false
  - Test that authentication redirects using `context.go()` work correctly
  - Test that route parameters (chatId) are passed and received correctly
  - Test that custom page transitions (fade, slide) display correctly
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 3. Fix navigation stack by using relative paths for nested routes

  - [~] 3.1 Update ProfileScreen navigation calls
    - Change `context.push(AppRoutes.editProfile)` to `context.push('edit')`
    - Change `context.push(AppRoutes.settings)` to `context.push('settings')`
    - File: `lib/features/profile/presentation/screens/profile_screen.dart`
    - _Bug_Condition: Using absolute path `/chats/profile/edit` or `/chats/settings` with context.push() from ProfileScreen_
    - _Expected_Behavior: Use relative paths 'edit' and 'settings' to maintain navigation hierarchy_
    - _Preservation: Keep context.go() usage for top-level navigation unchanged_
    - _Requirements: 2.1, 2.2, 2.6_

  - [~] 3.2 Update ContactsScreen navigation calls
    - Change `context.push(AppRoutes.search)` to `context.push('search')`
    - Change `context.push(AppRoutes.chatPath(chat.id))` to `context.push(chat.id.toString())`
    - File: `lib/features/contacts/presentation/screens/contacts_screen.dart`
    - _Bug_Condition: Using absolute paths `/chats/search` or `/chats/:chatId` with context.push() from ContactsScreen_
    - _Expected_Behavior: Use relative paths 'search' and chatId.toString() to maintain navigation hierarchy_
    - _Preservation: Keep context.go() usage for top-level navigation unchanged_
    - _Requirements: 2.3, 2.4, 2.7_

  - [~] 3.3 Update SearchScreen navigation calls
    - Change `context.push(AppRoutes.chatPath(chat.id))` to `context.push(chat.id.toString())`
    - File: `lib/features/contacts/presentation/screens/search_screen.dart`
    - _Bug_Condition: Using absolute path `/chats/:chatId` with context.push() from SearchScreen_
    - _Expected_Behavior: Use relative path chatId.toString() to maintain navigation hierarchy_
    - _Preservation: Keep context.go() usage for top-level navigation unchanged_
    - _Requirements: 2.7_

  - [~] 3.4 Update NewGroupScreen navigation calls
    - Change `context.push(AppRoutes.chatPath(chatId))` to `context.push(chatId.toString())`
    - File: `lib/features/chats/presentation/screens/new_group_screen.dart`
    - _Bug_Condition: Using absolute path `/chats/:chatId` with context.push() from NewGroupScreen_
    - _Expected_Behavior: Use relative path chatId.toString() to maintain navigation hierarchy_
    - _Preservation: Keep context.go() usage for top-level navigation unchanged_
    - _Requirements: 2.5, 2.7_

  - [~] 3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Navigation with Relative Paths Maintains Stack
    - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

  - [~] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Top-Level Navigation and Auth Redirects
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm all tests still pass after fix (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [~] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
