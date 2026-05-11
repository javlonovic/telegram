# Navigation Stack Bug - Counterexamples Documentation

## Bug Condition Exploration Test Results

**Test File**: `test/navigation_stack_bug_test.dart`  
**Test Status**: ✅ FAILED AS EXPECTED (confirms bug exists)  
**Date**: Bug exploration phase

## Summary

The bug condition exploration property test has successfully identified the navigation stack bug. All 4 test scenarios failed, confirming that using absolute paths with `context.push()` breaks the navigation stack in GoRouter.

## Counterexamples Found

### Counterexample 1: ChatsScreen → ProfileScreen
**Validates**: Requirement 1.1

**Test Scenario**:
- Start at `/chats` (ChatsScreen)
- Navigate using `router.push(AppRoutes.profile)` where `AppRoutes.profile = '/chats/profile'`
- Attempt to navigate back

**Expected Behavior**:
- Should find exactly 1 "Chats Screen" widget after navigation
- Should be able to pop back to ChatsScreen

**Actual Behavior (Bug)**:
```
Expected: exactly one matching candidate
Actual: Found 2 widgets with text "Chats Screen"
```

**Root Cause**: Using absolute path `/chats/profile` with `context.push()` causes GoRouter to create a duplicate route entry instead of properly nesting the route in the hierarchy.

---

### Counterexample 2: ChatsScreen → SettingsScreen
**Validates**: Requirement 1.2

**Test Scenario**:
- Start at `/chats` (ChatsScreen)
- Navigate using `router.push(AppRoutes.settings)` where `AppRoutes.settings = '/chats/settings'`
- Attempt to navigate back

**Expected Behavior**:
- Should find exactly 1 "Chats Screen" widget after navigation
- Should be able to pop back to ChatsScreen

**Actual Behavior (Bug)**:
```
Expected: exactly one matching candidate
Actual: Found 2 widgets with text "Chats Screen"
```

**Root Cause**: Same as Counterexample 1 - absolute path `/chats/settings` breaks the navigation hierarchy.

---

### Counterexample 3: ProfileScreen → EditProfileScreen
**Validates**: Requirement 1.6

**Test Scenario**:
- Start at `/chats` (ChatsScreen)
- Navigate to ProfileScreen using `router.push(AppRoutes.profile)`
- Navigate to EditProfileScreen using `router.push(AppRoutes.editProfile)` where `AppRoutes.editProfile = '/chats/profile/edit'`
- Attempt to navigate back

**Expected Behavior**:
- Should find exactly 1 "Profile Screen" widget after navigation
- Should be able to pop back through ProfileScreen to ChatsScreen

**Actual Behavior (Bug)**:
```
Expected: exactly one matching candidate
Actual: Found 2 widgets with text "Profile Screen"
```

**Root Cause**: Nested absolute path `/chats/profile/edit` compounds the problem, creating multiple duplicate entries in the navigation stack.

---

### Counterexample 4: Multiple Navigation and Back Button
**Validates**: Requirement 1.8

**Test Scenario**:
- Start at `/chats` (ChatsScreen)
- Navigate through multiple screens using absolute paths
- Attempt to navigate back through the stack

**Expected Behavior**:
- Navigation stack should grow with each push
- Back navigation should work correctly without black screens
- Should eventually return to ChatsScreen

**Actual Behavior (Bug)**:
```
Expected: exactly one matching candidate
Actual: Found 2 widgets with text "Chats Screen"
```

**Root Cause**: The broken navigation stack from absolute paths causes duplicate route entries, making back navigation unpredictable and potentially showing black screens.

---

## Technical Analysis

### Why Absolute Paths Break the Stack

GoRouter's nested route architecture expects:
- **Relative paths** for `context.push()` when navigating within a nested route hierarchy
- **Absolute paths** for `context.go()` when replacing the entire navigation stack

When using absolute paths like `/chats/profile` with `context.push()`:
1. GoRouter doesn't recognize this as a child of the current `/chats` route
2. It creates a new route entry that includes the parent route again
3. This results in duplicate widgets in the widget tree
4. The navigation stack becomes corrupted with duplicate entries
5. Back navigation fails because the stack structure is broken

### Expected Fix

Replace absolute paths with relative paths in `context.push()` calls:
- ❌ `context.push('/chats/profile')` → ✅ `context.push('profile')`
- ❌ `context.push('/chats/settings')` → ✅ `context.push('settings')`
- ❌ `context.push('/chats/profile/edit')` → ✅ `context.push('edit')`

## Test Execution Command

```bash
flutter test test/navigation_stack_bug_test.dart --reporter expanded
```

## Next Steps

1. ✅ Bug condition exploration test written and run (Task 1)
2. ⏭️ Write preservation property tests (Task 2)
3. ⏭️ Implement fix using relative paths (Task 3)
4. ⏭️ Re-run bug condition test - should PASS after fix (Task 3.5)
5. ⏭️ Verify preservation tests still pass (Task 3.6)
