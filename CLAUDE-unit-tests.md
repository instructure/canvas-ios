# Unit Testing Guide

This guide outlines the conventions and best practices for writing unit tests in the Canvas iOS projects. Follow these guidelines to ensure consistency and maintainability across the test suite.

## Important: Following These Conventions

**The tests in the codebase use all kinds of conventions.** When creating or updating test files:

- **When creating NEW test files**: DO NOT look for patterns in existing test files you think are related. ALWAYS use the conventions described in this guide.
- **When updating EXISTING test files**: It's okay to use the conventions of that file (no need to refactor the entire file), but any new additions (like new helper methods) should follow the conventions from this guide.

This ensures gradual migration toward consistent testing patterns across the codebase.

## File Structure and Naming

- Each tested file should have its `*Tests.swift` counterpart with a matching folder structure
- Tests should be placed under `CoreTests`, `StudentUnitTests`, `TeacherUnitTests`, etc., mirroring the structure of the source code

**Example:**
- Source: `Core/Core/Features/Submissions/Submission/Model/Entities/Submission.swift`
- Test: `Core/CoreTests/Features/Submissions/Submission/Model/Entities/SubmissionTests.swift`

## What to Test

- **Only test what is in the file itself**, not implementation details from protocols, dependencies, or other files
- Test non-private methods and properties
- Test computed properties and their logic
- Test initializers and factory methods
- Test edge cases and boundary conditions

## What NOT to Test

- **Static `make(...)` methods** (inside `#if DEBUG` blocks) - these are test helpers
- **Protocol conformance when the type does not implement it explicitly** - DO NOT test compiler-generated conformances
  - **General rule**: Only test protocol conformance if the type provides its own implementation in the file being tested
  - **Examples of what NOT to test**:
    - If a type declares `Equatable` conformance but has no custom implementation (compiler synthesizes it), DO NOT test equality
    - If a type declares `Codable` conformance but has no custom implementation (compiler synthesizes it), DO NOT test encoding/decoding
    - Same applies to any other protocol with compiler-generated conformance (e.g., `Hashable`, `Comparable` with automatic synthesis)
  - **Why**: Testing compiler-generated code tests the compiler, not your code
- **Implementation of non-private helpers** - these should be unit tested separately on their own
- Dependencies or external behavior (use mocks/stubs instead)

## Constants Management

### Class-Level Constants

Constants used across multiple test methods should be stored in a `testData` tuple property at the top of the test class:

```swift
final class MyClassTests: CoreTestCase {

    private static let testData = (
        id: "some id",
        name: "some name",
        grade1: "grade 1",
        grade2: "grade 2",
        date1: Date.make(year: 2025, month: 9, day: 15),
        date2: Date.make(year: 2025, month: 9, day: 20)
    )
    private lazy var testData = Self.testData

    // ... test methods
}
```

**Note:** If there is only one constant, use a `private static let` property instead (tuples must have multiple parameters).

### Method-Level Constants

If a constant is used only in one test method, it's acceptable to define it locally within that method.

### Constant Values Guidelines

#### String Values
- **Do not use real-world examples** - keep it simple
  - Good: `"some assignmentName"`, `"name 1"`, `"name 2"`
  - Bad: `"My Favorite Course Name"`, `"John's Assignment"`
- **Use numbered variations** for multiple similar values: `"name 1"`, `"name 2"`
- **Do not use empty strings** unless that's exactly what you want to test (avoid common fallback values)

#### Number Values
- **Do not use 0 or 1** unless that's exactly what you want to test (avoid common fallback values)
- Use meaningful values like `42`, `7`, `100`, etc.

#### Date Values
- **Use the `Date.make()` helper method**
  - Example: `Date.make(year: 2025, month: 9, day: 15)`
- **Do not overcomplicate** - year, month, day are usually enough
- Add hour, minute, second only when testing time-specific logic

## Test Method Naming

Follow this strict naming convention:

```
func test_subject_whenCondition_shouldExpectation()
func test_subject_withCondition_shouldExpectation()
```

### Rules:
- **The method name should summarize what the test does**
- Use `when` or `with` as appropriate to form a proper English sentence
- The **condition part can be omitted** when there is no meaningful condition
- The **expectation part can be omitted** when the method tests multiple cases or when it doesn't add meaningful information
- Expectation refers to the subject

### Examples:
```swift
func test_isGraded_whenScoreIsNil_shouldBeFalse()
func test_dueDates_shouldCallDateTextsProviderAndUseItsResult()
func test_basicProperties()
func test_score_withNoSubAssignments()
func test_itemStatus_shouldMatchSubAssignmentSubmissionStatus()
```

## Test Method Organization

### Single vs. Multiple Cases

**Create one test method for each test case** when:
- The test is more complex
- Each case requires significant setup
- Each case tests different aspects of functionality

**Merge multiple test cases into one method** when:
- The tests are simple and related
- They test variations of the same property/method
- Combining them improves readability

### GIVEN/WHEN/THEN Structure

**Do not use GIVEN/WHEN/THEN** for simple tests - separating using linebreaks is enough:

```swift
func test_score_withNoPointsPossible() {
    testee = makeListItem(.make(
        points_possible: nil,
        submission: .make(score: 42)
    ))

    XCTAssertEqual(testee.score, nil)
}
```

**Use WHEN/THEN pairs** for multiple cases in one method, with inline descriptions:

```swift
func test_score_withNoSubAssignments() {
    // WHEN has pointsPossible, has score
    var testee = makeListItem(.make(
        points_possible: 100,
        submission: .make(score: 42)
    ))
    // THEN
    XCTAssertEqual(testee.score, "42 / 100")

    // WHEN has pointsPossible, has no score
    testee = makeListItem(.make(
        points_possible: 100,
        submission: .make(score: nil)
    ))
    // THEN
    XCTAssertEqual(testee.score, "- / 100")
}
```

**Important:** When testing multiple cases in one method, declare the variable with `var` and reuse it across cases by reassigning:

```swift
func test_init_shouldSetIsSubmitted() {
    var testee = SubmissionStatus.make(
        isSubmitted: true
    )
    XCTAssertEqual(testee.isSubmitted, true)

    testee = SubmissionStatus.make(
        isSubmitted: false
    )
    XCTAssertEqual(testee.isSubmitted, false)
}
```

This pattern:
- Keeps the variable name consistent
- Makes it clear that subsequent cases are variations of the same test
- Avoids creating multiple variables with numbered suffixes (`testee1`, `testee2`, etc.)

### setUp and tearDown

**Use setUp and tearDown when you need initialization before each test.** Common use cases include setting up properties, initializing mocks, or configuring shared state. Do not add setUp/tearDown if you don't need initialization.

#### Rules:

1. **Always add tearDown when you add setUp** - This is mandatory to prevent state leaking between tests
2. **Property naming** - Name properties by their type/purpose, not their implementation:
   ```swift
   // Good
   private var dateTextsProvider: AssignmentDateTextsProviderMock!

   // Bad
   private var dateTextsProviderMock: AssignmentDateTextsProviderMock!
   ```

#### Pattern:

```swift
final class StudentAssignmentListItemTests: CoreTestCase {

    private var testee: StudentAssignmentListItem!
    private var dateTextsProvider: AssignmentDateTextsProviderMock!

    override func setUp() {
        super.setUp()
        dateTextsProvider = .init()
    }

    override func tearDown() {
        testee = nil
        dateTextsProvider = nil
        super.tearDown()
    }

    // ... test methods
}
```

#### Key Points:

- **Call super.setUp()** at the start of setUp
- **Call super.tearDown()** at the end of tearDown
- **Set all properties to nil** in tearDown to prevent memory leaks and state leaks
- **Reset global state** in tearDown if setUp modified it:
  - Clean up any global state that was set up
- **Declaration**: Declare properties as implicitly unwrapped optionals (`!`) so they can be set in setUp

### Grouping with MARKs

Use MARKs to separate groups of tests by subject:

```swift
// MARK: - Basic properties

func test_basicProperties_withNoSubAssignments() { }

// MARK: - Due dates

func test_dueDates_shouldCallDateTextsProvider() { }

// MARK: - Status

func test_status_withNoSubAssignments() { }
```

## Helper Methods

Helper methods keep test methods clean and focused:

```swift
// MARK: - Private helpers

private func makeViewModel(
    assignment: APIAssignment,
    submission: APISubmission? = nil
) -> StudentSubAssignmentsCardViewModel {
    let submissionModel = submission.map { Submission.make(from: $0, in: databaseClient) }
    return StudentSubAssignmentsCardViewModel(
        assignment: Assignment.make(from: assignment, in: databaseClient),
        submission: submissionModel
    )
}
```

### Guidelines:
- Add helper methods after a `// MARK: - Private helpers` mark at the end of the test class or file
- Use `private makeSomething()` methods to keep test methods simple
- **Use class properties as default parameter values** when appropriate
- The goal is to make callsites simple and show only meaningful parameters

## Assertions

### Assertion Preferences

1. **Prefer `XCTAssertEqual` over `XCTAssert`/`XCTAssertTrue`/`XCTAssertFalse`**
   ```swift
   // Good
   XCTAssertEqual(result, true)

   // Less preferred
   XCTAssertTrue(result)
   ```

2. **Prefer `XCTAssertEqual` over `XCTAssertNil`** when the type is Equatable
   ```swift
   // Good
   XCTAssertEqual(result, nil)

   // Acceptable (XCTAssertNotNil is okay to use)
   XCTAssertNotNil(result)
   ```

3. **Use custom assertions** defined in `Core/TestsFoundation/Assertions`

### Asserting String Literals

Assert against the **non-localized version** of the string:

```swift
XCTAssertEqual(DueDateFormatter.noDueDateText, "No Due Date")
XCTAssertEqual(testee.needsGrading, "7 Need Grading")
```

This is safe enough for testing purposes.

### Asserting Dates

Assert against **Date extensions** (from `Core/Common/Extensions/Foundation/DateExtensions.swift`), not hand-written strings:

```swift
// Good - tests the proper formatting is used
XCTAssertEqual(testee.dueDate, testData.date1.relativeDateTimeString)

// Bad - testing against a hand-written string
XCTAssertEqual(testee.dueDate, "Jan 15, 2025 at 2:30 PM")
```

This approach:
- Is more robust against region/locale issues
- Tests that the proper formatting method is being used
- Avoids brittle string comparisons

## Complete Examples

### Simple Test Class

```swift
final class DueDateFormatterTests: CoreTestCase {

    private static let testData = (
        date1: Date.make(year: 2025, month: 1, day: 15, hour: 14, minute: 30),
        date2: Date.make(year: 2025, month: 2, day: 10, hour: 9, minute: 15)
    )
    private lazy var testData = Self.testData

    // MARK: - Format using dates

    func test_format_whenDueDateNil_shouldReturnNoDueDateText() {
        XCTAssertEqual(
            DueDateFormatter.format(nil),
            DueDateFormatter.noDueDateText
        )
    }

    func test_format_whenDueDateProvided_shouldReturnFormattedDateWithPrefix() {
        XCTAssertEqual(
            DueDateFormatter.format(testData.date1),
            DueDateFormatter.dateText(testData.date1)
        )
    }
}
```

### Test Class with Helper Methods

```swift
final class StudentSubAssignmentsCardViewModelTests: StudentTestCase {

    private static let testData = (
        tag1: "tag1",
        tag2: "tag2",
        name1: "name 1",
        name2: "name 2"
    )
    private lazy var testData = Self.testData

    private var testee: StudentSubAssignmentsCardViewModel!

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(
            assignment: .make(
                has_sub_assignments: true,
                checkpoints: [
                    .make(tag: testData.tag1, name: testData.name1),
                    .make(tag: testData.tag2, name: testData.name2)
                ]
            )
        )

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.items.first?.id, testData.tag1)
        XCTAssertEqual(testee.items.first?.title, testData.name1)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        assignment: APIAssignment,
        submission: APISubmission? = nil
    ) -> StudentSubAssignmentsCardViewModel {
        let submissionModel = submission.map { Submission.make(from: $0, in: databaseClient) }
        return StudentSubAssignmentsCardViewModel(
            assignment: Assignment.make(from: assignment, in: databaseClient),
            submission: submissionModel
        )
    }
}
```

## Reference Test Files

Study these files as excellent examples of the conventions described above:

- `Student/StudentUnitTests/Assignments/AssignmentDetails/SubAssignmentsCard/ViewModel/StudentSubAssignmentsCardViewModelTests.swift`
- `Core/CoreTests/Features/Assignments/Assignment/Model/Utilities/AssignmentDateTextsProviderTests.swift`
- `Core/CoreTests/Common/CommonUI/Formatters/DueDateFormatterTests.swift`
- `Core/CoreTests/Common/CommonUI/Formatters/DueDateSummaryTests.swift`
- `Core/CoreTests/Features/Assignments/AssignmentList/Model/StudentAssignmentListItemTests.swift`
- `Core/CoreTests/Features/Assignments/AssignmentList/Model/TeacherAssignmentListItemTests.swift`
