# GitHub Copilot Preferences

## Project Context

- Canvas is a learning management system with multiple iOS and iPadOS apps (Student, Teacher, Parent)
- The Canvas xcworkspace consists of multiple Xcode projects
- There is a standalone Xcode project for each app (Student, Teacher, Parent)
- The apps share a common Core project for shared code
- The apps are written in Swift and use a mix of UIKit and SwiftUI
- The workspace uses SwiftLint for code style and formatting
- The workspace uses XcodeGen for generating the Xcode project files 

## Response Preferences

- Be concise and prioritize code examples
- Suggest Swift solutions with proper typing
- Use Swift, SwiftUI and Combine best practices appropriately
- Reference existing project patterns when suggesting new implementations
- When explaining code, focus on implementation details and potential edge cases

## Tool Usage Preferences

- Prefer searching through codebase before suggesting solutions
- Use error checking after code edits

## Code Style Preferences
- Don't add comments or documentation unless its specifically requested
- Avoid explanatory comments in code, especially in test files (no "// First create...", "// Verify...", etc.)
- Code should be self-explanatory without inline comments
- When generating test files, only include license headers and the actual test code without explanatory comments
- When formatting the code, use SwiftLint rules defined in the project

## Implementation Preferences
- Follow project's component structure and naming conventions
- Use existing utility functions and shared components when possible
- Ensure the code compiles and runs without errors
- If you create a new file, ensure you call `make sync` in the terminal so the file is added to the Xcode project
- When writing tests, make sure the tests pass
