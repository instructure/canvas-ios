# Testing Conventions

## Presenter Tests

When writing presenter tests there are a few conventions to adhere to in order to help keep the tests as stable as possible.

### PersistenceTestCase

Because a presenter has many integration points, such as the api, router, database, etc... we have created mocks/stubs for each of these integration points. By subclassing `PersistenceTestCase` you will have access to all of these mocked integrations. The less you are exercising these integrations and focusing on the code in the presenter, the more stable your tests will be. These mocks include:

 - TestRouter
 - TestEnvironment
 - TestLogger
 - MockUploadManager
 - MockURLSession
 - TestStore
 - An in memory test database
 - A mock session

### Testing `Store` and `UseCase`

We have tests that exercise the logic and integrations of a Store and a UseCase. It's best that we not exercise this logic inside of the presenter as this opens the door to a lot of flakiness. By exercising everything involved in the store and use cases it involves doing round multiple trips to the database as well as hitting the mocked api. Combined all these things tend to introduce potential flakiness. Instead we should first test that we are setting up our `UseCase`s properly.

```
func testUseCasesSetupProperly() {
  XCTAssertEqual(presenter.courses.useCase.courseID, presenter.courseID)

  XCTAssertEqual(presenter.assignments.useCase.courseID, presenter.courseID)
  XCTAssertEqual(presenter.assignments.useCase.assignmentID, presenter.assignmentID)
  XCTAssertEqual(presenter.assignments.useCase.include, [.submission])

  XCTAssertEqual(presenter.arc.useCase.courseID, presenter.courseID)
}
```

Next we will want to test to make sure that our `Store` callbacks are triggering updates to our view. We will typically set up a protocol for our view controller that we can then mock inside of our tests.

```
extension MyPresenterTests: MyViewProtocol {
  func update() {
    updateExpectation.fulfill()
  }

  func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
    resultingSubtitle = subtitle
    resultingBackgroundColor = backgroundColor
  }
}
```

As the example shows we typically have at least two methods in our protocol, one for generic updates and another for updating the nav bar. If my `Store` only updates the nav bar I might write a test such as this

```
func testLoadCourse() {
  let course = Course.make()
  presenter.course.eventHandler()
  XCTAssertEqual(resultingSubtitle, course.name)
}
```

If my test runs the `update` method I might write a test like this

```
func testLoadAssignment() {
  let assignment = Assignment.make()
  presenter.assignment.eventHandler()
  wait(for: [updateExpectation], timeout: 0.1)
  XCTAssertEqual(presenter.assignment.first, assignment)
}
```

The `updateExpectation` here is just to ensure that the `update` method was called, and should not be asynchronous (unless you are doing something async in your presenter after the event handler is called). With this approach you will also want to make sure that in your `setUp` method you recreate the `updateExpecation` so you have a fresh one for every test.

Next we will write a test to ensure that our `viewIsReady` method on our presenter is refreshing/exhausting the stores properly. These tests will utilize the `TestStore` class which has stubbed out methods for `refresh`, `exhaust`, and `getNextPage` methods. A test for `viewIsReady` might look like this

```
func testViewIsReady() {
  presenter.viewIsReady()
  let coursesStore = presenter.courses as! TestStore
  let assignmentsStore = presenter.assignments as! TestStore
  let colorsStore = presenter.colors as! TestStore
  let arcStore = presenter.arc as! TestStore

  presenter.viewIsReady()
  wait(for: [
    coursesStore.refreshExpectation,
    assignmentsStore.refreshExpectation,
    colorsStore.refreshExpectation,
    arcStore.refreshExpectation
  ], timeout: 0.1)
}
```

Beyond this we should just try to make sure that any tests that require some data to already be seeded in the database, we do so with `ModelName.make()` and not doing `api.mock(...)` and then running through the whole Store routine. This will introduce many possible points of failure. Also if your test really doesn't need to create anything in the database, don't. Just create the data you need and run your tests.

Another gotcha is that you should recreate your presenter in `setUp` so that each test has a fresh presenter to work with.

For a mostly comprehensive example check out `AssignmentDetailsPresenterTests.swift`