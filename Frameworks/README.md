iOS Frameworks
==============

## Getting Started

Here are a few things to help you hit the ground running.

### 1. Carthage

We use [Carthage](https://github.com/Carthage/Carthage) for package management.
To install the dependencies, run the following:

```
carthage checkout --no-use-binaries
```

## Unit Tests

There is a parent class called `UnitTestCase` which unit test cases can
subclass to get some nice helpers for things like stubbing network requests.
This is also a good place to put shared test code.

```swift
class MyModelTestCase: UnitTestCase {

  override func setUp() {
    super.setUp()
  }

}
```

### Stubbing Network Requests

The `UnitTestCase` parent class has a `session` property that can be used to
test networking code. We are using [Mockingjay](https://github.com/kylef/Mockingjay)
for stubbing HTTP requests.

Mockingjay uses matchers and builders to stub specific requests.

Here is an example of stubbing a simple `GET request:

```swift
// define a matcher using the `session` so the baseURL and other boilerplate
// is handled for us
let matcher = session.match(.GET, "/courses")

// define the desired response
let body = ["courses": [["id": "12345"]]]

// finally, stub the matcher with the response
stub(matcher, builder: json(body))

// set and use the request like normal
let request = try! session.GET("/courses")
session.URLSession.JSONSignalProducer(request)
  .startWithNext { json in
    // your assertions here
  }
```

You can do fancy things like stubbing responses containing headers. Here we
stub a couple pagination responses using headers:

```swift
let headers = ["Link": "<\(session.baseURL.absoluteString)/pages?page=2&per_page=99>; rel=\"next\""]
let page1Matcher = session.match(.GET, "/pages")
let page2Matcher = session.match(.GET, "/pages", parameters: ["page": 2])

stub(page1Matcher, builder: json(["pages": [["one": "a"]]], headers: headers))
stub(page2Matcher, builder: json(["pages": [["two": "b"]]]))
```
