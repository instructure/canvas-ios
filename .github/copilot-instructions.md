# GitHub Copilot Preferences

## Project Context

- Canvas is a learning management system with multiple iOS and iPadOS apps (Student, Teacher, Parent)
- The Canvas xcworkspace consists of multiple Xcode projects
- There is a standalone Xcode project for each app (Student, Teacher, Parent)
- The apps share a common Core project for shared code
- The Student app includes two experiences, Canvas Academic and Canvas Career
- Canvas Career has its' own project called Horizon
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
- When given a ticket identifier, use Atlassian MCP server to gather information about the task
- When given a Figma link, use Figma MCP server to gather design details

## Code Style Preferences
- Follow SwiftLint rules strictly - they are enforced in all Swift files
- The following is critical: Only add explanatory inline code comments if you are specifically asked to, the code should be self-explanatory 

## Implementation Preferences
- Follow project's component structure and naming conventions
- Use existing utility functions and shared components when possible
- If you are working inside the Horizon project and you are taksed to create a new UI component, check the existing HorizonUI Design System to compose the new component if possible. If needed, create new components in the design system.
- Ensure the code compiles and runs without errors
- If you create a new file, ensure you call `make sync` in the terminal so the file is added to the Xcode project
- When writing tests, make sure the tests pass
- When you are asked to write tests, ensure they are written in the same manner as existing tests in the project

## Building and Testing Preferences
- When you invoke xcodebuild to build for test, use the `CITests` scheme
- When you invoke xcodebuild to build for run or test, use the latest iOS Simulator available