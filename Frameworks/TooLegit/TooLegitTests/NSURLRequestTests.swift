//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import XCTest
import TooLegit
import DoNotShipThis
import SoAutomated

class NSURLRequestTests: XCTestCase {
    func testBasicGETRequest() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("")
            XCTAssertEqual(request.URL, NSURL(string: "https://ibm.com/?per_page=99"))
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }
    
    func testGETBananas() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("bananas")
            XCTAssertEqual(request.URL, NSURL(string: "https://ibm.com/bananas?per_page=99"))
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }
    
    func testGETBananasWherePeeled() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("bananas", parameters: ["peeled": "true"])
            XCTAssertEqual(request.URL, NSURL(string: "https://ibm.com/bananas?peeled=true&per_page=99"))
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }
    
    func testGETArrayParameter() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("a", parameters: ["foo": ["bar"]])
            XCTAssertEqual(request.URL, NSURL(string: "https://ibm.com/a?foo[]=bar&per_page=99"))
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }
    
    func testGETDictionaryParameter() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("b", parameters: ["foo": ["bar": "baz", "ebb": "flow"]])
            let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)
            let query = components?.queryItems ?? []
            XCTAssertTrue(query.contains(NSURLQueryItem(name: "foo[bar]", value: "baz")))
            XCTAssertTrue(query.contains(NSURLQueryItem(name: "foo[ebb]", value: "flow")))
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }
    
    func testGET3Parameters() {
        attempt {
            let session = Session.ibm
            let request = try session.GET("c", parameters: ["one": "a", "two": "b", "three": "c"])
            let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)
            let query = components?.queryItems ?? []
            XCTAssertTrue(query.contains(NSURLQueryItem(name: "one", value: "a")))
            XCTAssertTrue(query.contains(NSURLQueryItem(name: "two", value: "b")))
            XCTAssertTrue(query.contains(NSURLQueryItem(name: "three", value: "c")))
            XCTAssertTrue(request.URL?.absoluteString?.componentsSeparatedByString("&").count == 4) // includes `per_page`
            XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
            XCTAssertNil(request.HTTPBody)
            XCTAssertFalse(request.allHTTPHeaderFields?.isEmpty ?? false)
            XCTAssertEqual("Bearer asdf1223", request.allHTTPHeaderFields?["Authorization"])
        }
    }

    func testBasicPOSTRequest() {
        attempt {
            let session = Session.ibm
            let parameters = ["one": "a", "two": "b"]
            let request = try session.POST("post", parameters: parameters)
            XCTAssertEqual(request.HTTPMethod, Method.POST.rawValue)
            XCTAssertNotNil(request.HTTPBody, "HTTPBody should not be nil")
            XCTAssertEqual(
                request.valueForHTTPHeaderField("Content-Type") ?? "",
                "application/json",
                "Content-Type should be application/json"
            )

            if let HTTPBody = request.HTTPBody {
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(HTTPBody, options: .AllowFragments)

                    if let JSON = JSON as? NSObject {
                        XCTAssertEqual(JSON, parameters as NSObject, "HTTPBody JSON does not equal parameters")
                    } else {
                        XCTFail("JSON should be an NSObject")
                    }
                } catch {
                    XCTFail("JSON should not be nil")
                }
            } else {
                XCTFail("JSON should not be nil")
            }
        }
    }

    func testHeaders_whenAuthorized_containsAuthorizationHeader() {
        let session = Session.ibm
        var request: NSURLRequest!

        attempt {
            request = try session.GET("get", authorized: true)
        }

        XCTAssert(request.authorized("asdf1223"))
    }

    func testHeaders_isAuthorizedByDefault() {
        let session = Session.ibm
        var request: NSURLRequest!

        attempt {
            request = try session.GET("get")
        }

        XCTAssert(request.authorized("asdf1223"))
    }

    func testHeaders_whenNotAuthorized_doesNotContainAuthorizationHeader() {
        let session = Session.ibm
        var request: NSURLRequest!

        attempt {
            request = try session.GET("get", authorized: false)
        }

        XCTAssertNil(request.allHTTPHeaderFields?["Authorization"])
    }

    func testURL_whenMasquerading_containsUserID() {
        let session = Session.masquerade
        var request: NSURLRequest!

        attempt {
            request = try session.GET("get")
        }

        let containsUserID = request.URL?.absoluteString?.rangeOfString("as_user_id=1") != nil
        XCTAssert(containsUserID)
    }

    func testURL_whenNotMasquerading_doesNotContainUserID() {
        let session = Session.ibm
        var request: NSURLRequest!

        attempt {
            request = try session.GET("get")
        }

        let containsUserID = request.URL?.absoluteString?.rangeOfString("as_user_id=1") != nil
        XCTAssertFalse(containsUserID)
    }

}

// MARK: - Helpers

extension NSURLRequest {
    private func authorized(token: String) -> Bool {
        return allHTTPHeaderFields?["Authorization"] == "Bearer \(token)"
    }
}

let _ibm: ()->Session = {
    let user = SessionUser(id: "2", name: "John", loginID: nil, sortableName: "john", email: nil, avatarURL: nil)
    return Session(baseURL: NSURL(string: "https://ibm.com")!, user: user, token: "asdf1223")
}

let _masquerade: ()->Session = {
    let user = SessionUser(id: "2", name: "John", loginID: nil, sortableName: "john", email: nil, avatarURL: nil)
    return Session(baseURL: NSURL(string: "https://ibm.com")!, user: user, token: "abc123", masqueradeAsUserID: "1")
}

extension Session {
    private static var ibm: Session { return _ibm() }
    private static var masquerade: Session { return _masquerade() }
}
