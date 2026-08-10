# NeoVote Flutter Mobile Application

## Project Purpose

NeoVote is a secure, modern, mobile-first voting platform for institutions, universities, NGOs, and organizations that need transparent and verifiable digital elections. The Flutter app should deliver a trusted voter experience with secure login, election browsing, ballot casting, real-time notifications, and secure payment handling for service access.

The application must be built with strong mobile UI/UX principles, clean architecture, and professional Flutter coding standards. The goal is to provide a product that feels trustworthy, simple, fast, and secure from first launch to final vote confirmation.

## What the Flutter Project Should Implement

The mobile application should include:

- Secure authentication with Firebase Authentication
- Google sign-in and biometric login
- Election discovery and ballot participation
- Secure vote submission flow
- Real-time notifications and reminders
- Multi-language support
- Offline-safe behavior where possible
- Payment integration support for Stripe and M-Pesa
- Accessibility, localization, and responsive mobile UI
- Strong security, modular architecture, and reusable widgets

## Recommended Development Principles

Follow these practices throughout the project:

- Use clean architecture with feature-first folders
- Keep business logic separate from UI logic
- Use dependency injection or service classes for backend access
- Prefer immutable state and typed models
- Use null safety and avoid dynamic where possible
- Keep widgets small, focused, and reusable
- Use constants for colors, spacing, typography, and strings
- Write readable code with clear naming and short functions
- Handle errors with custom exceptions and user-friendly messages
- Add tests for core logic and critical flows

## Best Coding Practices for This Project

1. Folder-by-feature structure
   - Group related screens, providers, services, and models together
2. Clear separation of concerns
   - UI, state, domain logic, and infrastructure each should have a distinct role
3. Reusable UI components
   - Buttons, input fields, cards, dialogs, loaders, and headers must be shared widgets
4. Consistent naming
   - Use descriptive names like `LoginPage`, `ElectionCard`, `AuthRepository`
5. Safe and predictable state handling
   - Avoid mixing UI rendering and network logic in the same widget
6. Performance awareness
   - Avoid unnecessary rebuilds, use `const` constructors, and keep lists efficient
7. Security-first implementation
   - Never store sensitive auth data insecurely
8. Accessibility support
   - Add semantic labels, sufficient contrast, and readable text sizes

## UI/UX Design Principles to Follow

The UI and UX must be guided by the following principles:

- Clarity: users should understand the next step immediately
- Consistency: spacing, colors, typography, and component behavior should remain uniform
- Feedback: every action should show progress, success, or error feedback
- Simplicity: reduce cognitive load and avoid clutter
- Trust: the design must feel secure, calm, and professional
- Accessibility: support larger text, screen readers, and contrast-aware design
- Responsiveness: the app should feel correct on phones of different sizes
- Familiarity: use common mobile patterns such as bottom sheets, cards, progress indicators, and clear forms

## UI/UX Design Guidance for the App

Use these design foundations:

- Use a calm, modern color system with strong contrast
- Apply consistent spacing scale such as 8, 12, 16, 24, 32
- Keep primary actions visible and clearly labeled
- Use cards for elections, actions, and summaries
- Implement skeleton loaders for network operations
- Provide empty states and error states for all meaningful screens
- Use sticky headers and clear navigation for large form flows
- Prefer biometrics and one-tap actions where security allows

## Widget Design Knowledge Required

To implement the app properly, the developer should understand these Flutter widget concepts:

- `StatelessWidget` and `StatefulWidget`
- `MaterialApp`, `ThemeData`, and `ColorScheme`
- `Scaffold`, `AppBar`, `BottomNavigationBar`, `Drawer`
- `TextFormField`, `ElevatedButton`, `OutlinedButton`, `TextButton`
- `ListView`, `GridView`, `PageView`
- `Container`, `Padding`, `SizedBox`, `Expanded`, `Spacer`
- `AlertDialog`, `SnackBar`, `BottomSheet`
- `FutureBuilder`, `StreamBuilder`, `AnimatedSwitcher`
- `CustomScrollView`, `SliverAppBar`, `SliverList`
- `Form`, `GlobalKey<FormState>`
- `AnimatedContainer`, `Hero`, `Opacity`, `ClipRRect`

Developers should also understand responsive UI patterns, theming, screen sizes, and platform-specific design behavior for Android and iOS.

## Project Architecture and File Structure

The project follows a modular, feature-first Clean Architecture. This ensures that the code is scalable, testable, and maintainable.

### Root Files
- [main.dart](file:///C:/Users/student/StudioProjects/neovote/lib/main.dart) - Application entry point, service initialization, and root widget.
- [firebase_options.dart](file:///C:/Users/student/StudioProjects/neovote/lib/firebase_options.dart) - Firebase configuration for multiple platforms.

### Core Module (`lib/core/`)
Contains shared logic, widgets, and infrastructure services.

- **Data Services**: [offline_service.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/data/services/offline_service.dart) - Handles local caching and offline behavior.
- **Errors**: [app_exception.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/errors/app_exception.dart), [failure.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/errors/failure.dart), [error_handler.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/errors/error_handler.dart).
- **Network**: [api_client.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/network/api_client.dart), [network_info.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/network/network_info.dart).
- **Presentation**: [neovote_button.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/presentation/widgets/neovote_button.dart) - Primary reusable button component.
- **Storage**: [secure_storage_service.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/storage/secure_storage_service.dart), [local_storage_service.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/storage/local_storage_service.dart), [database_service.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/storage/database_service.dart).
- **Utils**: [validators.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/utils/validators.dart), [logger.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/utils/logger.dart), [formatters.dart](file:///C:/Users/student/StudioProjects/neovote/lib/core/utils/formatters.dart).

### Features Module (`lib/features/`)
Each feature is encapsulated with its own data, presentation, and logic layers.

#### Authentication (`auth`)
- **Pages**: [login_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/presentation/pages/login_page.dart), [signup_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/presentation/pages/signup_page.dart).
- **Widgets**: [auth_header.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/presentation/widgets/auth_header.dart), [social_login_button.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/presentation/widgets/social_login_button.dart).
- **Logic**: [auth_repository.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/data/repositories/auth_repository.dart), [auth_provider.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/auth/providers/auth_provider.dart).

#### Elections (`elections`)
- **Pages**: [election_list_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/elections/presentation/pages/election_list_page.dart), [election_detail_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/elections/presentation/pages/election_detail_page.dart).
- **Data**: [election_model.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/elections/data/models/election_model.dart), [election_repository.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/elections/data/repositories/election_repository.dart).

#### Payments (`payments`)
- **Services**: [payment_service.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/payments/data/services/payment_service.dart) - Integration for Stripe and M-Pesa.

#### Voting (`voting`)
- **Pages**: [voting_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/voting/presentation/pages/voting_page.dart), [vote_confirmation.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/voting/presentation/pages/vote_confirmation.dart).
- **Data**: [ballot_model.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/voting/data/models/ballot_model.dart), [voting_repository.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/voting/data/repositories/voting_repository.dart).

#### Notifications (`notifications`)
- **Data**: [notification_model.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/notifications/data/models/notification_model.dart), [notification_repository.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/notifications/data/repositories/notification_repository.dart).
- **UI**: [notifications_page.dart](file:///C:/Users/student/StudioProjects/neovote/lib/features/notifications/presentation/pages/notifications_page.dart).

## Payment Integration Details

### Stripe
The application uses `flutter_stripe` for secure card processing. Initialization occurs in `main.dart` and the logic is encapsulated in `PaymentService`.

### M-Pesa
M-Pesa integration is handled via STK Push (Lipa na M-Pesa Online). The `PaymentService` manages the authentication and request dispatch to the Safaricom API using the provided consumer keys.

## Multi-language Support
Localized strings are supported for:
- **English (en)**
- **Swahili (sw)**

Configured in `MaterialApp` via `localizationsDelegates` and `supportedLocales`.

## Recommended Dependencies

Add the following packages as the app grows:

```yaml
dependencies:
  firebase_core: latest
  firebase_auth: latest
  google_sign_in: latest
  local_auth: latest
  http: latest
  shared_preferences: latest
  flutter_localizations: latest
```

## Final Implementation Notes

This project should be treated as a trust-focused, security-first mobile product. The design must feel simple, premium, and calm while still providing strong confidence in the voting process. Every screen should support clear user guidance, safe actions, and error prevention. The codebase should stay modular, scalable, and maintainable from the first release onward.
