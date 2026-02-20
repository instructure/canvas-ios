# CLAUDE

## Project Context

- Canvas is a learning management system with multiple iOS and iPadOS apps (Student, Teacher, Parent)
- The Canvas xcworkspace consists of multiple Xcode projects
- There is a standalone Xcode project for each app (Student, Teacher, Parent)
- The apps share a common Core project for shared code
- The Student app includes two experiences, Canvas Academic and Canvas Career
- Canvas Career has its own project called Horizon
- The apps are written in Swift and use a mix of UIKit and SwiftUI
- The project follows MVVM (Model-View-ViewModel) architecture pattern
- The workspace uses SwiftLint for code style and formatting
- The workspace uses XcodeGen for generating the Xcode project files
- Dependencies are managed using Swift Package Manager (SPM)

## Project Structure

The workspace root contains the following key projects:

- **Student App**: `./Student` - Canvas Academic student experience
- **Teacher App**: `./Teacher` - Teacher experience
- **Parent App**: `./Parent` - Parent experience
- **Core**: `./Core` - Shared framework used by all apps
- **Horizon**: `./Horizon` - Canvas Career (Student app second experience)
- **Main Workspace**: `./Canvas.xcworkspace`

### Key Directories

- **Shared utilities**: `Core/Core/Common/Extensions/`
- **Shared components**: `Core/Core/Common/CommonUI/`
- **Shared models**: `Core/Core/Common/CommonModels/`
- **InstUI Design System**: `Core/Core/Common/CommonUI/InstUI/` — see @Core/Core/Common/CommonUI/InstUI/CLAUDE.md for patterns
- **HorizonUI Design System**: `Horizon/Horizon/Sources/Common/View/`

## Response Preferences

- Be concise and prioritize code examples
- Suggest Swift solutions with proper typing
- Use Swift, SwiftUI and Combine best practices appropriately
- Use Combine for reactive programming (no async/await currently)
- Reference existing project patterns when suggesting new implementations
- When explaining code, focus on implementation details and potential edge cases

## Tool Usage Preferences

- Prefer searching through codebase before suggesting solutions
- Use error checking after code edits
- When given a ticket identifier (e.g., MBL-12345), use Atlassian MCP server to gather information about the task
- When given a Figma link, use Figma MCP server to gather design details
- When building the project prefer using XcodeBuildMCP, instead of invoking xcodebuild from command line
- When building for test, use the `CITests` scheme
- Use the latest iOS Simulator available

## Code Style Preferences
- Follow SwiftLint rules strictly - they are enforced in all Swift files
- The following is critical: Only add explanatory inline code comments if you are specifically asked to, the code should be self-explanatory 

## Implementation Preferences
- Follow project's component structure and naming conventions
- Use existing utility functions and shared components from the Key Directories listed above
- If working inside the Horizon project, use the HorizonUI Design System to compose new UI components
- When working on UI inside Core, Student, Parent or Teacher projects, use elements from InstUI and CommonUI helpers
- Ensure the code compiles and runs without errors
- After creating new files or modifying project settings, run `make sync` to update Xcode projects via XcodeGen
- When writing tests, make sure the tests pass
- When you are asked to write tests, follow the conventions outlined in CLAUDE-unit-tests.md

