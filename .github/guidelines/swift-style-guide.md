# Instructure Swift Style Guide

This guide is to be used with Swift 5.10.

It is based on [Kodeco](https://github.com/kodecocodes/swift-style-guide/blob/main/README.markdown) and [Google](https://google.github.io/swift/) Swift style guides. We introduced further tweaks to accomodate our needs and practices.

A large amount of the rules here are enforced by swiftlint, but not all. Some are more like guidelines rather than hard rules.

All rules are intended for production code. Test and preview code allows for somewhat different, less strict practices. Those are not described in this document.

## Table of Contents

* [Naming](#naming)
  * [Namespacing](#namespacing)
  * [Boolean Properties and Methods](#boolean-properties-and-methods)
  * [Acronyms](#acronyms)
  * [Generics](#generics)
* [Code Organization](#code-organization)
  * [Extensions](#extensions)
  * [Protocol Definitions](#protocol-definitions)
  * [Protocol Conformance](#protocol-conformance)
  * [Marks](#marks)
  * [Imports](#imports)
* [Spacing](#spacing)
  * [Identation](#indentation)
  * [Trailing Whitespace](#trailing-whitespace)
  * [Horizontal Spacing](#horizontal-spacing)
  * [Horizontal Alignment](#horizontal-alignment)
  * [Vertical Spacing](#vertical-spacing)
* [Line-wrapping](#line-wrapping)
  * [Braces](#braces)
  * [Column Limit](#column-limit)
  * [Function Declarations](#function-declarations)
  * [Function Calls](#function-calls)
* [Classes and Structures](#classes-and-structures)
  * [Use of self](#use-of-self)
  * [Variables](#variables)
  * [Computed Properties](#computed-properties)
  * [Lazy Properties](#lazy-properties)
  * [Constants](#constants)
  * [Final](#final)
* [Closure Expressions](#closure-expressions)
  * [Closure Parameters](#closure-parameters)
  * [Trailing Closure Syntax](#trailing-closure-syntax)
  * [Single Line Closures](#single-line-closures)
  * [Chained Methods](#chained-methods)
  * [Key Path Syntax](#key-path-syntax)
* [Control Flow](#control-flow)
  * [If Statements](#if-statements)
  * [Guard Statements](#guard-statements)
  * [Early Exit](#early-exit)
  * [Ternary Operator](#ternary-operator)
  * [Switch Statements](#switch-statements)
* [Access Control](#access-control)
  * [Keyword Ordering](#keyword-ordering)
  * [Public](#public)
  * [Internal](#internal)
  * [Fileprivate](#fileprivate)
  * [Extension Access Levels](#extension-access-levels)
* [Optionals](#optionals)
  * [Unwrapping Optionals](#unwrapping-optionals)
  * [Optional Chaining and Binding](#optional-chaining-and-binding)
  * [Checking for nil](#checking-for-nil)
* [Misc](#misc)
  * [Semicolons](#semicolons)
  * [Implicit Returns](#implicit-returns)
  * [Default Parameter Values](#default-parameter-values)
  * [Parentheses](#parentheses)
  * [Trailing Commas](#trailing-commas)
  * [Void](#void)
  * [Attributes, Property Wrappers, Macros](#attributes-property-wrappers-macros)
  * [Comments](#comments)
  * [TODOs](#todos)
  * [Multi-line String Literals](#multi-line-string-literals)

## Naming

Use the Swift naming conventions described in the [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). 

Some additonal notes:
- prefer clarity over brevity
- avoid overly generic names for types of specific funtionality
- prefer US English spelling to match Apple's API  
  (`color` instead of `colour`, `favorites` instead of `favourites`, etc.)

### Namespacing

When naming a type with a specific functionality consider prefixing it with the domain in which it is used. (like `CalendarEventDetailsScreen` instead of `EventDetailsScreen` or `DetailsScreen`)

Do not abreviate prefixes. There are few specific exceptions to this rule (`API`, `CD`, ...), but prefer not to introduce more.

Consider nesting helper types as a form of namespacing. At the moment this can not be done for protocols.

When namespacing constants, prefer to add them to enums as `static let` type properties. For namespacing purposes use enums instead of structs.

### Boolean Properties and Methods
Use prefixes like `is`, `can`, `has` etc. in bool properties or methods.

- **Preferred**:
```swift
var isEnabled: Bool
var isSubtitleVisible: Bool

func updateScreen(hasContent: Bool)
```

- **Not Preferred**:
```swift
var enabled: Bool
var subtitleVisible: Bool
var visibleSubtitle: Bool

func updateScreen(content: Bool)
```

Try to avoid double negation.

- **Preferred**:
```swift
var isVisible: Bool

if isEditable { ... }
```

- **Not Preferred**:
```swift
var isNotHidden: Bool

if !isUneditable { ... }
if !isNotEditable { ... }
```

### Acronyms
Avoid all-capitalized acronyms.

Exceptions are some type name prefixes, but we use only a few specific prefixes like this (`API`, `CD`, ...).

- **Preferred**:
```swift
func handleHttpError(_ error: HttpError)
struct APICalendarEvent { }
```

- **Not Preferred**:
```swift
func handleHTTPError(_ error: HTTPError)
```

### Generics

Generic type parameters should be descriptive, upper camel case names. When a type name doesn't have a meaningful relationship or role, use a traditional single uppercase letter such as `T`, `U`, or `V`.

- **Preferred**:
```swift
struct Stack<Element> { ... }
func write<Target: OutputStream>(to target: inout Target)
func swap<T>(_ a: inout T, _ b: inout T)
```

- **Not Preferred**:
```swift
struct Stack<T> { ... }
func write<target: OutputStream>(to target: inout target)
func swap<Thing>(_ a: inout Thing, _ b: inout Thing)
```

## Code Organization

Most swift source files should contain the following:
- One (primary) type, which matches the file name.
- Closely related code, like its extensions, helper types, private helper extensions, nested types, etc.

If a helper is non-private and not small enough or not trivial, it's preferred to put it in its own file. No hard rule here, use your best judgement.

If a helper type is meaningful on its own and is reused elsewhere, extract it to its own file. This is usually needed when a helper component was initially private, but it's being reused elsewhere. In those cases don't just remove `private`, but consider relocating the component.

Larger extensions can also be moved to their own file, named like `PrimaryType+TopicOfExtension` or `PrimaryType+ProtocolTheExtensionConfromsTo`.

### Extensions

Using extensions to organize code inside a file is optional. Using just marks to group methods is also fine. Use your best judgement.

When using extensions for organization, prefer to preceed them with a `// MARK: -` comment.

### Protocol Definitions

Protocols intended only for DI should be defined right before their primary conforming type, in the same file.

Protocols with multiple conforming types should usually go into their own file and each type also into their own. In simple cases it's also okay to put the protocol and all the conforming types into one file. Use your best judgement here.

### Protocol Conformance

If a protocol is very simple or conformance is generated (eg.: `Codable`), prefer adding conformance inline at the type definition.

If a protocol has multiple members or it is more complex, prefer adding a separate extension for the protocol methods.

### Marks

Prefer to use `// MARK: -` comments to keep things well-organized. They can be used before extensions or to group methods or some properties. Do not omit the `-`.

Always put a blank line before a mark. If a mark groups multiple methods or types, put a blank line after it.

Be consistent within a file. If you use marks, make sure the groups are "closed". Add a mark after the group ends (unless it's the end of file), preferably with a mark of the next group. If there is no meaningful next group use a closing mark: `// MARK: Group name -` (note the `-` after the name, not before as usual).

### Imports

Import only the modules a source file requires. For example, don't import `UIKit` when importing `Foundation` will suffice. Likewise, don't import `Foundation` if you must import `UIKit`.

Prefer to sort imports alphabetically.

- **Preferred**:
```swift
import UIKit
var view: UIView
var deviceModels: [String]
```

- **Preferred**:
```swift
import Foundation
var deviceModels: [String]
```

- **Not Preferred**:
```swift
import UIKit
import Foundation
var view: UIView
var deviceModels: [String]
```

- **Not Preferred**:
```swift
import UIKit
var deviceModels: [String]
```

## Spacing

### Indentation

Indent using **4 spaces** rather than tabs. Be sure to set Xcode preferences accordingly.

### Trailing Whitespace

Do not leave trailing horizontal whitespace at end of line. Not even when it is an otherwise empty line. Be sure to set Xcode preferences accordingly.

At the end of file keep exactly one blank line.

### Horizontal Spacing

When you need to put a space between expressions always use a single space.

Colons always have no space on the left and one space on the right. Exceptions are the ternary operator `? :`, empty dictionary `[:]` and `#selector` syntax `addTarget(_:action:)`.

- **Preferred**:
```swift
class TestDatabase: Database {
    var data: [String: CGFloat] = ["A": 1.2, "B": 3.2]
}
```

- **Not Preferred**:
```swift
class TestDatabase : Database {
    var data :[String:CGFloat] = ["A" : 1.2, "B":3.2]
}
```

Refer to https://google.github.io/swift/#horizontal-whitespace, except the paragraph about spaces around `//`.

### Horizontal Alignment

Do not align type names, default values, etc. horizontally.

Prefer not to create columns when defining arrays, unless it really makes them more readable. Keep in mind those alignments will need extra maintenance when code changes in the future.

### Vertical Spacing

Feel free to group code logically with blank lines within a block of code, but be consistent, at least within a file.

Always use only a single blank line when you want to separate groups of code.

Always put a blank line between methods, types, extensions. This is optional between methods in protocol definitions.

Do not put a blank line after a codeblock's opening delimiter (eg.: `(`, `{`, `[`), unless it's a type. It is okay to put a blank line after a type's opening brace. Prefer to not use it for small helper types, though.

Do not put a blank line before a closing delimiter (eg.: `)`, `}`, `]`) which is on its own line. If you really want to separate an `else` put the line break between the `}` and the `else`.

## Line-wrapping

### Braces

* Method braces and other braces (`if`/`else`/`switch`/`while` etc.) always open on the same line as the statement but close on a new line.

- **Preferred**:
```swift
if user.isHappy {
    // Do something
} else {
    // Do something else
}
```

- **Not Preferred**:
```swift
if user.isHappy
{
    // Do something
}
else {
    // Do something else
}
```

### Column Limit

Aim to keep a column limit of `120` characters. It's recommended to set Xcode preferences accordingly.

Exceptions:
- Lines where obeying the column limit is not possible without breaking a meaningful unit of text that should not be broken (for example, a long URL in a comment, long localizable string).
- Test method names.
- Code generated by another tool.

### Function Declarations

Keep short function declarations on one line including the opening brace:

```swift
func reticulateSplines(spline: [Double]) -> Bool {
    // reticulate code goes here
}
```

For functions with long signatures, put each parameter on a new line and add an extra indent on subsequent lines:

- **Preferred**:
```swift
func reticulateSplines(
    spline: [Double], 
    adjustmentFactor: Double,
    translateConstant: Int, 
    comment: String
) -> Bool {
    // reticulate code goes here
}
```

- **Not Preferred**:
```swift
func reticulateSplines(spline: [Double], 
                       adjustmentFactor: Double,
                       translateConstant: Int, 
                       comment: String) -> Bool {
  // reticulate code goes here
}
```

This is also supported by Xcode: with the cursor on a parameter press `CTRL-M` to wrap and indent.

### Function Calls

Mirror the style of function declarations at call sites. Calls that fit on a single line should be written as such:

```swift
let success = reticulateSplines(splines)
```

If the call site must be wrapped, put each parameter on a new line, indented one additional level, and put the closing parentheses on a new line as well:

- **Preferred**:
```swift
let success = reticulateSplines(
    spline: splines,
    adjustmentFactor: 1.3,
    translateConstant: 2,
    comment: "normalize the display"
)
```

- **Not Preferred**:
```swift
let success = reticulateSplines(spline: splines,
                                adjustmentFactor: 1.3,
                                translateConstant: 2,
                                comment: "normalize the display")
```

## Classes and Structures

### Use of self

For conciseness, avoid using `self` since Swift does not require it to access an object's properties or invoke its methods.

Use `self` only when required by the compiler (in `@escaping` closures, or in initializers to disambiguate properties from parameters). In other words, if it compiles without `self` then omit it.

In initializers where some properties require `self` and some don't (which have no matching parameter name) it's okay to use `self` for all of them, for consistency.

Prefer not to use `self` in closures after `guard let self`.

### Variables

Always use `let` instead of `var` if the value of the variable will not change. A good technique is to define everything using `let` and only change it to `var` if the compiler complains!

### Computed Properties

For conciseness, if a computed property is read-only, omit the `get` clause. The `get` clause is required only when a `set` clause is provided.

- **Preferred**:
```swift
var diameter: Double {
    radius * 2
}
```

- **Not Preferred**:
```swift
var diameter: Double {
    get {
        radius * 2
    }
}
```

### Lazy Properties

If the initialization of a lazy property is just a few lines, prefer to use an immediately called closure `{ }()`.
If it is longer or more complex consider extracting that code to a private factory method.

### Constants

Prefer to define constants inside the type which uses them instead of using global constants, even if they are private.

Consider namespacing constants under a nested enum if you define more of them.

```swift
struct FixedSizeButton {
    private enum Size {
        static let width: CGFloat = 42
        static let height: CGFloat = 24
    }

    private enum Padding {
        static let horizontal: CGFloat = 8
        static let vertical: CGFloat = 4
    }

    ...
}
```

### Final

Marking classes or members as `final` is preferred but not required.

## Closure Expressions

### Closure Parameters

Give the closure parameters descriptive names. Use shorthand syntax (`$0`, `$1`) only when the purpose of the parameter is clear.

Do not put parentheses around closure parameters, unless they are a tuple.

### Trailing Closure Syntax

Use trailing closure syntax only if there's a single closure expression parameter at the end of the argument list. Prefer to not use it if the purpose of the parameter is not clear at the call site.

Do not leave empty parentheses after the function name, when a function called with trailing closure syntax takes no other arguments.

When using multiple closures as parameters, make sure to follow the line break rules. This allows for clear identation.

**Exception:** SwiftUI code may follow different rules.

- **Preferred**:
```swift
UIView.animate(withDuration: 1.0) {
    self.myView.alpha = 0
}

UIView.animate(
    withDuration: 1.0,
    animations: {
        self.myView.alpha = 0
    },
    completion: { finished in
        self.myView.removeFromSuperview()
    }
)

let squares = [1, 2, 3].map { $0 * $0 }
```

- **Not Preferred**:
```swift
UIView.animate(
    withDuration: 1.0,
    animations: {
        self.myView.alpha = 0
    }, completion: { finished in
        self.myView.removeFromSuperview()
    }
)

UIView.animate(withDuration: 1.0, animations: {
    self.myView.alpha = 0
}, completion: { finished in
    self.myView.removeFromSuperview()
})

UIView.animate(withDuration: 1.0, animations: {
    self.myView.alpha = 0
}) { finished in
    self.myView.removeFromSuperview()
}

let squares = [1, 2, 3].map() { $0 * $0 }
```

### Single Line Closures

It is okay to write simpler closures on a single line. In that case leave one space inside the braces. When not using a trailing syntax do not leave spaces between the parentheses and braces.

- **Preferred**:
```swift
let value = numbers.map { $0 * 2 }

if let value = numbers.map({ $0 * 2 }) { ... }
```

- **Not Preferred**:
```swift
let value = numbers.map {$0 * 2}
let value = numbers.map{ $0 * 2 }

if let value = numbers.map({$0 * 2}) { ... }
```

### Chained Methods

Chained methods using trailing closures should be clear and easy to read in context. Decisions on spacing, line breaks, and when to use named versus anonymous arguments is left to the discretion of the author. Examples:

```swift
let value = numbers.map { $0 * 2 }.filter { $0 % 3 == 0 }.index(of: 90)

let value = numbers
    .map { $0 * 2 }
    .filter { $0 > 50 }
    .map { $0 + 10 }
```

### Key Path Syntax

Consider using keypaths instead of closure bodies if it helps clarity. But do not overuse it for the sake of brevity.

```swift
let names = people.map(\.name)
```

## Control Flow

### If Statements

When multiple conditions are wrapped:
- Keep the first condition on the same line as the `if` keyword.
- Left align conditions under each other. (Xcode does this by default)
- The opening brace should be on the same line as the last condition.

### Guard Statements

Prefer to put a blank line after a `guard` statement.

When multiple conditions are wrapped:
- Keep the first condition on the same line as the `guard` keyword.
- Left align conditions under each other. (Xcode does this by default)
- The `else {` should be kept together either on the same line as the last condition or on a new line.

If the `else` clause is a simple return (like `return`, `return nil`, `return false`, etc.) and it doesn't cause wrapping, prefer the compact form like `else { return }`.
If the return value is significant, not trivial or you want to ephasize it, do not use the compact form.
When multiple conditions are wrapped, do not use the compact form on the same line as the last condition. It's okay to use it on a new line.

### Early Exit

In general, prefer to use `guard` for early exit instead of `if` with a `return`.

When the condition would be more natural using an `if`, it's okay to use it instead. (i.e.: to avoid double negation or to simplify the condition)

Prefer to put a blank line after the `if` statement in this case.

### Ternary Operator

Feel free to use the ternary operator `?:` for assignments and returns.

Prefer to evaluate only a single condition and to provide simple results. Prefer using `if-else` statement if any of the clauses needs to be wrapped or if it's complex.

When wrapping the operator's clauses, prefer to add an extra indent. (This is against current Xcode auto-indentation, but helps readability.)

Avoid nesting ternary operators.

It's okay to add parentheses around the condition if it helps clarity.

- **Preferred**:
```swift
result = value != 0 ? x : y

result = value != 0 
    ? someVeryLongResultWhichWouldCauseReachingTheColumnLimit
    : anotherVeryLongResultWhichWouldCauseReachingTheColumnLimit

result = (value == 0) ? x : y
```

- **Not Preferred**:
```swift
result = a > b ? x = c > d ? c : d : y

result = value != 0
    ? doSomething(
          parameter1: 1,
          parameter2: 2
      )
    : doAnoterThing()
```

### Switch Statements

Cases should be indented at the same level as the `switch` keyword. (Xcode does this by default)

The body of a case could be either kept on the same line or put on a new line.

Avoid using `fallthrough`. Put multiple cases together instead.
Multiple cases could be listed either on the same line or on new lines.

Prefer not using `default`. List every case explicitly instead. This way the compiler will force us to handle newly added cases, instead of potentially causing subtle bugs.

## Access Control

Prefer to use the strictest access level.

When something could be `private`, make it so. This helps reasoning about usages of the given property or method (or type). Although Xcode can be used (most of the time) to find usages, you still need to have the code checked out first.

### Keyword Ordering

Use access control as the leading property specifier, even when using `static`, `lazy` or `override`. The only things that should come before access control are attributes and property wrappers.

### Public

If a component is designed to be reused anywhere, make it `public`. In that case make all of its non-`private` members `public` as well.

If a type is not made `public`, but it's assumed that it may need to be in the future, handle its members in one of these two ways:
- Either leave all of its non-`private` members implicitly internal.
- Or make all of its non-`private` members `public`.

Eaither way is okay, they have their own pros and cons. Just make sure all members are consistently either `public` or (implicitly) internal.

### Internal

When internal is the default access level omit the `internal` keyword.

**Exception:** Define a property or method explicitly as `internal` when it should be `private`, but made `internal` only for testing purposes. Consider refactoring the code before using this "workaround".

### Fileprivate

Prefer `private` over `fileprivate`.

### Extension Access Levels

Avoid using `public extension`. Instead keep the extension (implicitly) internal and make all of its non-`private` members `public`.

It is okay to use `private extension`, as it is a more contained case.

## Optionals

### Unwrapping Optionals

Do not use forced unwrapping in production code.

Prefer not to use implicitly unwrapped optional types for properties in production code. Prefer optional binding to implicitly unwrapped optionals in most other cases.

### Optional Chaining and Binding

When accessing an optional value, use optional chaining if the value is only accessed once or if there are many optionals in the chain:

```swift
textContainer?.textLabel?.setNeedsDisplay()
```

Use optional binding when it's more convenient to unwrap once and perform multiple operations:

```swift
if let userName = user.name { ... }
```
Whenever possible, use the shorthand syntax for unwrapping optionals into shadowed variables:

```swift
if let textContainer { ... }
```

### Checking for nil

Conditional statements that test whether an Optional is non-`nil` but do not access the wrapped value, should be written as comparisons to `nil`.

- **Preferred**:
```swift
if value != nil {
    print("value was not nil")
}
```

- **Not Preferred**:
```swift
if let _ = value {
    print("value was not nil")
}
```

## Misc

### Semicolons

Swift does not require a semicolon after each statement in your code. They are only required if you wish to combine multiple statements on a single line.

Do not write multiple statements on a single line separated with semicolons.

### Implicit Returns

Prefer to omit the `return` keyword for computed properties, methods or closures where the body is a oneliner.

In other simpler cases it's also preferred to omit it, but it's okay either way.

It's okay to omit it when returning results of simple `if-else` or `switch` statements.

### Default Parameter Values

Parameters with default values are not required to be in the last postions.

Prefer to set trivial defaults, which could be reasonably guessed on the call site.

Do not overuse default parameter values. Keep in mind that while default values help keeping the call site clean, they can also introduce ambiguity.

### Parentheses

Parentheses around conditionals are not required and should be omitted.

- **Preferred**:
```swift
if name == "Hello" {
    print("World")
}
```

- **Not Preferred**:
```swift
if (name == "Hello") {
    print("World")
}
```

It's okay to use parentheses when it improves clarity: in complex cases or to be explicit about precedence.

- **Preferred**:
```swift
let playerMark = (player == current ? "X" : "O")
```

### Trailing Commas

Do not use trailing commas in arrays and dictionaries.

### Void

In function type declarations (such as closures, or variables holding a function reference), write the return type as `Void`, not as `()`.

In functions declared with the `func` keyword, omit the `Void` return type entirely.

To represent the lack of an input simply use `()`, not `(Void)`.

- **Preferred**:
```swift
func doSomething() { ... }

let callback: () -> Void

typealias CompletionHandler = (Bool) -> Void
```

- **Not Preferred**:
```swift
func doSomething() -> Void { ... }

func doSomething2() -> () { ... }

let callback: () -> ()

typealias CompletionHandler = (Result) -> ()
```

### Attributes, Property Wrappers, Macros

Attributes `@IBOutlet`, `@IBAction`, `@objc`, `@NSManaged` should be in the same line as the member, before other specifiers.

Other attributes should be in their own line.

Property wrappers should be in the same line as the property, before other specifiers.

_[TODO: Macros]_

### Comments

When they are needed, use comments to explain **why** a particular piece of code does something. Comments must be kept up-to-date or deleted.

Prefer extracting complex code into self-describing helper methods (or types), instead of adding comments to it.

Avoid the use of C-style comments (`/* ... */`). Prefer the use of double- or triple-slash.

### TODOs
Leaving `// TODO:` or `// FIXME:` comments in the code should be rare. In those cases prefer to create and link a followup ticket in the comment.

### Multi-line String Literals

When building a long string literal, you're encouraged to use the multi-line string literal syntax. An exception is when a string is copy-pasted from the design as-is.

Open the literal on the same line as the assignment, but do not include text on that line. Indent the text block one additional level.

- **Preferred**:
```swift
let message = """
    You cannot charge the flux \
    capacitor with a 9V battery.
    You must use a super-charger \
    which costs 10 credits. You currently \
    have \(credits) credits available.
    """
```

- **Not Preferred**:
```swift
let message = """You cannot charge the flux \
    capacitor with a 9V battery.
    You must use a super-charger \
    which costs 10 credits. You currently \
    have \(credits) credits available.
    """
```

- **Not Preferred**:
```swift
let message = "You cannot charge the flux " +
    "capacitor with a 9V battery.\n" +
    "You must use a super-charger " +
    "which costs 10 credits. You currently " +
    "have \(credits) credits available."
```
