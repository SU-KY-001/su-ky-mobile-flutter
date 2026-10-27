# AGENTS.md — lib/

- Imports: `package:` for cross-folder, relative only within the same feature
  folder is fine; follow `directives_ordering`.
- File names `snake_case.dart`; one public class per file where practical.
- Prefer `const` constructors, `final` locals, trailing commas.
- Utility holders are `abstract final class` with static members.
- Do not put business logic in `main.dart` or `app/`.
- Adding a package: `flutter pub add <pkg>`, commit `pubspec.lock`, note why
  in the PR.
