# Bugfix Requirements Document

## Introduction

The navigation stack in the Telegram clone Flutter app is broken, causing users to see a black/blank screen when pressing the back button instead of returning to the previous screen. This occurs because screens are using `context.push()` with full absolute paths (e.g., `/chats/profile`) instead of relative paths (e.g., `profile`) when navigating to nested routes under `/chats`. GoRouter's nested route architecture requires relative paths for proper navigation stack management.

The app uses GoRouter with a hierarchical structure where `/chats` is the root authenticated screen, and all other authenticated screens (profile, settings, contacts, chat details, etc.) are nested children. When full paths are used with `context.push()`, GoRouter loses track of the navigation hierarchy, resulting in a broken back stack.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a user navigates from ChatsScreen to ProfileScreen using `context.push(AppRoutes.profile)` where `AppRoutes.profile = '/chats/profile'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.2 WHEN a user navigates from ChatsScreen to SettingsScreen using `context.push(AppRoutes.settings)` where `AppRoutes.settings = '/chats/settings'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.3 WHEN a user navigates from ChatsScreen to ContactsScreen using `context.push(AppRoutes.contacts)` where `AppRoutes.contacts = '/chats/contacts'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.4 WHEN a user navigates from ChatsScreen to SearchScreen using `context.push(AppRoutes.search)` where `AppRoutes.search = '/chats/search'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.5 WHEN a user navigates from ChatsScreen to NewGroupScreen using `context.push(AppRoutes.newGroup)` where `AppRoutes.newGroup = '/chats/new-group'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.6 WHEN a user navigates from ProfileScreen to EditProfileScreen using `context.push(AppRoutes.editProfile)` where `AppRoutes.editProfile = '/chats/profile/edit'` THEN the system pushes the route but breaks the navigation stack hierarchy

1.7 WHEN a user navigates from ChatsScreen or ContactsScreen to a specific chat using `context.push(AppRoutes.chatPath(chatId))` where the result is `/chats/:chatId` THEN the system pushes the route but breaks the navigation stack hierarchy

1.8 WHEN a user presses the back button after navigating via any of the above broken push calls THEN the system displays a black/blank screen instead of the previous screen

### Expected Behavior (Correct)

2.1 WHEN a user navigates from ChatsScreen to ProfileScreen THEN the system SHALL use `context.push('profile')` with a relative path to maintain proper navigation stack hierarchy

2.2 WHEN a user navigates from ChatsScreen to SettingsScreen THEN the system SHALL use `context.push('settings')` with a relative path to maintain proper navigation stack hierarchy

2.3 WHEN a user navigates from ChatsScreen to ContactsScreen THEN the system SHALL use `context.push('contacts')` with a relative path to maintain proper navigation stack hierarchy

2.4 WHEN a user navigates from ChatsScreen to SearchScreen THEN the system SHALL use `context.push('search')` with a relative path to maintain proper navigation stack hierarchy

2.5 WHEN a user navigates from ChatsScreen to NewGroupScreen THEN the system SHALL use `context.push('new-group')` with a relative path to maintain proper navigation stack hierarchy

2.6 WHEN a user navigates from ProfileScreen to EditProfileScreen THEN the system SHALL use `context.push('edit')` with a relative path to maintain proper navigation stack hierarchy

2.7 WHEN a user navigates from ChatsScreen or ContactsScreen to a specific chat THEN the system SHALL use `context.push(chatId.toString())` with just the chat ID as a relative path to maintain proper navigation stack hierarchy

2.8 WHEN a user presses the back button after navigating via any of the above corrected push calls THEN the system SHALL display the previous screen correctly without showing a black/blank screen

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user navigates using `context.go()` for top-level navigation (e.g., from login to chats) THEN the system SHALL CONTINUE TO use full absolute paths as this is correct for replacing the entire navigation stack

3.2 WHEN a user presses back and `context.canPop()` returns false THEN the system SHALL CONTINUE TO use `context.go(AppRoutes.chats)` as a fallback to navigate to the root screen

3.3 WHEN a user is on any screen and presses back with a valid navigation stack THEN the system SHALL CONTINUE TO use `context.pop()` to return to the previous screen

3.4 WHEN the authentication state changes and redirects occur THEN the system SHALL CONTINUE TO use `context.go()` with full paths for navigation

3.5 WHEN custom page transitions (fade, slide) are applied to routes THEN the system SHALL CONTINUE TO display these transitions correctly

3.6 WHEN route parameters are passed (e.g., chatId in ChatScreen) THEN the system SHALL CONTINUE TO receive and use these parameters correctly
