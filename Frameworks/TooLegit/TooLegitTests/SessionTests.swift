//
//  SessionTests.swift
//  TooLegitTests
//
//  Created by Derrick Hathaway on 12/22/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import XCTest
import TooLegit
import ReactiveCocoa
import Marshal
import SoAutomated
import DoNotShipThis
import Nimble

let currentBundle = NSBundle(forClass: SessionTests.self)

class SessionTests: XCTestCase {
    func testGET() {
        let session = httpBinSession()
        var response: JSONObject?

        session.playback("get", in: currentBundle) {
            waitUntil { done in
                let request = try! session.GET("/get")
                session.JSONSignalProducer(request).startWithCompletedAction(done) { response = $0 }
            }
        }

        XCTAssertEqual("https://httpbin.org/get?per_page=99", response?["url"] as? String)
    }

    func testPOST() {
        let session = httpBinSession()
        var response: JSONObject?

        session.playback("post", in: currentBundle) {
            waitUntil { done in
                let request = try! session.POST("/post", parameters: ["foo": "bar"])
                session.JSONSignalProducer(request).startWithCompletedAction(done) { response = $0 }
            }
        }

        XCTAssertEqual("bar", (response?["json"] as? JSONObject)?["foo"] as? String)
    }

    func testPUT() {
        let session = httpBinSession()
        var response: JSONObject?

        attempt {
            let request = try session.PUT("/put", parameters: ["type": "put"])
            session.playback("put", in: currentBundle) {
                waitUntil { done in
                    session.JSONSignalProducer(request).startWithCompletedAction(done) { response = $0 }
                }
            }
        }

        XCTAssertNotNil(response)
    }

    func testDELETE() {
        let session = httpBinSession()
        var response: JSONObject?

        attempt {
            let request = try session.DELETE("/delete", parameters: ["type": "delete"])
            session.playback("delete", in: currentBundle) {
                waitUntil { done in
                    session.JSONSignalProducer(request).startWithCompletedAction(done) { response = $0 }
                }
            }
        }

        XCTAssertNotNil(response)
    }

    func testRACDataWithRequestCompletesMoreThanOnce() {
        let session = httpBinSession()
        attempt {

            let request = try! session.GET("/get")
            let dataProducer = session.rac_dataWithRequest(request)

            session.playback("get", in: currentBundle) {
                waitUntil { done in
                    dataProducer.startWithCompletedAction(done)
                }
            }

            session.playback("get", in: currentBundle) {
                waitUntil { done in
                    dataProducer.startWithCompletedAction(done)
                }
            }
        }
    }

    func testRemovingNilValuesFromJSON_whenThereAreNilValues_theirKeysAreRemoved() {
        let nillable: [String: AnyObject?] = [
            "nil": nil,
            "non-nil": 1
        ]

        let value = Session.rejectNilParameters(nillable)

        XCTAssertFalse(value.keys.contains("nil"))
    }

    func testComparingSessions_whenTokensAreEqual_theSessionsAreTheSame() {
        let one = quickSession("abc", url: "http://google.com", userID: "1", userName: "john")
        let two = quickSession("abc", url: "http://instructure.com", userID: "2", userName: "jim")

        let same = one.compare(two) && two.compare(one)

        XCTAssert(same, "the sessions are the same")
    }

    func testComparingSessions_whenUserIDsAreEqual_theSessionsAreNotTheSame() {
        let one = quickSession(nil, url: "http://google.com", userID: "1", userName: "john")
        let two = quickSession("abc", url: "http://instructure.com", userID: "1", userName: "jim")

        let same = one.compare(two) && two.compare(one)

        XCTAssertFalse(same, "the sessions are not the same")
    }

    func testComparingSessions_whenBaseURLsAreEqual_theSessionsAreNotTheSame() {
        let one = quickSession(nil, url: "http://google.com", userID: "1", userName: "john")
        let two = quickSession("abc", url: "http://google.com", userID: "2", userName: "jim")

        let same = one.compare(two) && two.compare(one)

        XCTAssertFalse(same, "the sessions are not the same")
    }

    func testComparingSessions_whenUserIDsAndBaseURLsAreEqual_theSessionsAreTheSame() {
        let one = quickSession(nil, url: "http://google.com", userID: "1", userName: "john")
        let two = quickSession("abc", url: "http://google.com", userID: "1", userName: "jim")

        let same = one.compare(two) && two.compare(one)

        XCTAssert(same, "the sessions are not the same")
    }

    func testPersistenceDirectoryPath_whenLocalStoreDirectoryIsTheDefault_isADirectoryInTheFileSystem() {
        let session = Session.build(localStoreDirectory: .Default)
        let directoryURL = session.localStoreDirectoryURL
        var isDir: ObjCBool = true
        guard let path = directoryURL.path else {
            XCTFail("expected a path")
            return
        }
        let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
        XCTAssert(exists, "it exists")
        XCTAssert(isDir, "it is a directory")
    }

    func testConvertingSessionToAndFromJSON_yieldsValidSession() {
        let json = Session.build(token: "abc").dictionaryValue()
        let fromJSON = Session.fromJSON(json)
        XCTAssertNotNil(fromJSON)
    }

    func testCreatingSessionFromJSON_whenJSONIsInvalid_yieldsNil() {
        let invalidJSON: [String: AnyObject] = [:]
        let fromJSON = Session.fromJSON(invalidJSON)
        XCTAssertNil(fromJSON)
    }

    func testSession_emptyResponseSignalProducer_swallowsResponse() {
        let session = httpBinSession()
        var request: NSURLRequest!
        attempt {
            request = try session.GET("/get")
        }

        session.playback("get", in: currentBundle) {
            waitUntil { done in
                session.emptyResponseSignalProducer(request).startWithCompletedAction(done)
            }
        }
    }

    func testSession_paginatedJSONSignalProducer_getsAllPages() {
        let session: Session = Session.nas
        var response: [JSONObject]?
        var request: NSURLRequest!
        attempt {
            request = try session.GET("/api/v1/courses/24219/assignments", parameters: ["per_page": 10])
        }

        session.playback("get-paginated", in: currentBundle) {
            waitUntil { done in
                session.paginatedJSONSignalProducer(request).startWithCompletedAction(done) { response = $0 }
            }
        }

        XCTAssertNotNil(response, "response should not be nil")
        XCTAssertGreaterThan(10, response?.count ?? 0, "response should contain all pages")
    }

    func testSession_responseJSONSignalProducer_whenResponseIsInvalid_sendsFailure() {
        let session = httpBinSession()
        var error: NSError?

        // given invalid response
        let statusCode = 404
        let url = NSURL(string: "https://instructure.com")!
        let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: nil)!

        // given dummy data
        let data = sampleData([:])

        // when
        let expectation = expectationWithDescription("response failed")
        session.responseJSONSignalProducer(data, response: response).startWithFailed {
            error = $0
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        // then
        let reasonExists = error?.localizedFailureReason?.rangeOfString("Expected a response in the 200-299 range. Got 404") != nil
        XCTAssert(reasonExists, "error has the expected failure reason")
    }

    func testSession_responseJSONSignalProducer_whenResponseIsValid_sendsJSONResponse() {
        let session = httpBinSession()
        var json: JSONObject?

        // given valid response
        let statusCode = 200
        let url = NSURL(string: "https://instructure.com")!
        let response = NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: nil)!

        // given data
        let jsonData: JSONObject = ["foo": "bar"]
        let data = sampleData(jsonData)

        // when
        waitUntil { done in
            session.responseJSONSignalProducer(data, response: response).startWithCompletedAction(done) { json = $0 }
        }

        guard let result = json else {
            XCTFail("json response should not be nil")
            return
        }
        XCTAssertEqual(1, result.keys.count, "json response should have one key")
        XCTAssertEqual("bar", result["foo"] as? String, "json response key/value should match")
    }

    func testSession_copyToBackgroundSession_setsConfigurationIdentifier() {
        let session = quickSession("abc123", url: "https://instructure.com", userID: "1", userName: "jo")
        let backgroundSession = session.copyToBackgroundSessionWithIdentifier("abc123", sharedContainerIdentifier: nil)
        XCTAssertEqual("abc123", backgroundSession.URLSession.configuration.identifier, "configuration identifer should match")
    }

    func testSession_copyToBackgroundSession_setsSharedContainerIdentifier() {
        let session = quickSession("abc123", url: "https://instructure.com", userID: "1", userName: "jo")
        let backgroundSession = session.copyToBackgroundSessionWithIdentifier("abc123", sharedContainerIdentifier: "123abc")
        XCTAssertEqual("123abc", backgroundSession.URLSession.configuration.sharedContainerIdentifier, "configuration shared container identifer should match")
    }

    func testSession_copyToBackgroundSession_setsBackgroundSessionDelegate() {
        let session = quickSession("abc123", url: "https://instructure.com", userID: "1", userName: "jo")
        let backgroundSession = session.copyToBackgroundSessionWithIdentifier("abc123", sharedContainerIdentifier: "123abc")
        XCTAssert(backgroundSession === backgroundSession.URLSession.delegate, "background session should be its own delegate")
    }

    // MARK: Helpers

    private func quickSession(token: String?, url: String, userID: String, userName: String) -> Session {
        let url = NSURL(string: url)!
        let user = SessionUser(id: userID, name: userName)
        return Session(baseURL: url, user: user, token: token)
    }

    private func httpBinSession() -> Session {
        return Session(baseURL: NSURL(string: "https://httpbin.org")!, user: SessionUser(id: "", name: ""), token: nil)
    }

    private func sampleData(json: JSONObject) -> NSData {
        var data: NSData!
        attempt {
            data = try NSJSONSerialization.dataWithJSONObject(json, options: [])
        }
        return data
    }
}
