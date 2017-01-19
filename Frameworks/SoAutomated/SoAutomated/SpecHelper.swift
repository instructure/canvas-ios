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
    
    

import CoreLocation
import Photos
import AVFoundation
import WebKit
import Nimble
import DVR
import TooLegit
@testable import SoPersistent
import ReactiveSwift
import CoreData
import Quick
import Result
import SoLazy

class SpecHelperConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        // increase default poll interval because Core Data change notifications are slow.
        Nimble.AsyncDefaults.PollInterval = 0.5

        // increase default timeout because sometimes even stubbed network calls can be slow.
        Nimble.AsyncDefaults.Timeout = 8
    }
}

extension Refresher {
    public func refreshAndWait(_ timeout: TimeInterval = Nimble.AsyncDefaults.Timeout) {
        waitUntil(timeout: timeout) { done in
            self.refreshingCompleted.observeValues { error in
                expect(error).to(beNil())
                delay(0.05) { done() }
            }
            self.refresh(true)
        }
    }

    @available(*, deprecated, message: "Use playback(name:with:timeout:) because all recordings should be in SoAutomated.")
    public func playback(_ name: String, in bundle: Bundle, with session: TooLegit.Session, timeout: TimeInterval = Nimble.AsyncDefaults.Timeout) {
        playback(name, with: session, timeout: timeout)
    }

    public func playback(_ name: String, with session: TooLegit.Session, timeout: TimeInterval = Nimble.AsyncDefaults.Timeout) {
        session.playback(name) {
            refreshAndWait(timeout)
        }
    }
}

extension TooLegit.Session {
    @available(*, deprecated, message: "Use playback(name:block:) because all recordings should be in SoAutomated.")
    public func playback(_ name: String, in bundle: Bundle, block: ()->Void) {
        playback(name, block: block)
    }

    public func playback(_ name: String, block: ()->Void) {
        let URLSession = self.URLSession

        // remove User-Agent header temporarily because it varies from target to target
        let userAgent = URLSession.configuration.httpAdditionalHeaders?["User-Agent"]
        URLSession.configuration.httpAdditionalHeaders?.removeValue(forKey: "User-Agent")

        // remove Accept-Language header
        let acceptLanguage = URLSession.configuration.httpAdditionalHeaders?["Accept-Language"]
        URLSession.configuration.httpAdditionalHeaders?.removeValue(forKey: "Accept-Language")

        let DVRSession = DVR.Session(outputDirectory: "~/Desktop/", cassetteName: name, testBundle: .soAutomated, backingSession: URLSession)
        self.URLSession = DVRSession
        DVRSession.beginRecording()
        block()
        DVRSession.endRecording()
        
        self.URLSession = URLSession
        self.URLSession.configuration.httpAdditionalHeaders?["User-Agent"] = userAgent
        self.URLSession.configuration.httpAdditionalHeaders?["Accept-Language"] = acceptLanguage
    }

    public func cacheInvalidated(_ key: String) -> Bool {
        let refreshingMoc = try! managedObjectContext(SoRefreshingStoreID)
        let refresh: Refresh? = try! refreshingMoc.findOne(withValue: key, forKey: "key")
        return refresh != nil
    }
}

// MARK: - RAC+SoAutomated

public enum TestError: Int {
	case `default` = 0
	case error1 = 1
	case error2 = 2
}

extension TestError: Error {
}

extension SignalProducerProtocol {
	/// Halts if an error is emitted in the receiver signal.
	/// This is useful in tests to be able to just use `startWithNext`
	/// in cases where we know that an error won't be emitted.
	public func assumeNoErrors() -> SignalProducer<Value, NoError> {
		return self.lift { $0.assumeNoErrors() }
	}
}

extension SignalProtocol {
	/// Halts if an error is emitted in the receiver signal.
	/// This is useful in tests to be able to just use `startWithNext`
	/// in cases where we know that an error won't be emitted.
	public func assumeNoErrors() -> Signal<Value, NoError> {
		return self.mapError { error in
			fatalError("Unexpected error: \(error)")

			()
		}
	}
}

extension SignalProducerProtocol {
    public func startWithCompletedAction(_ doneAction: @escaping () -> Void, file: StaticString = #file, line: UInt = #line, next: ((Value) -> Void)? = nil) -> Disposable {
        return start { event in
            switch event {
            case .value(let v): next?(v)
            case .completed: DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { doneAction() }
            case .interrupted: XCTFail("interrupted", file: file, line: line)
            case .failed(let error): XCTFail("failed \(error)")
            }
        }
    }

    public func startWithFailedAction(_ doneAction: @escaping () -> Void, file: StaticString = #file, line: UInt = #line, failed: ((Error) -> Void)? = nil) -> Disposable {
        return start { event in
            switch event {
            case .value, .completed: break
            case .interrupted: XCTFail("interrupted", file: file, line: line)
            case .failed(let error):
                failed?(error)
                doneAction()
            }
        }
    }

    public func startAndWaitForCompleted(_ next: ((Value) -> Void)? = nil) {
        var disposable: Disposable?
        waitUntil { done in
            disposable = self.startWithCompletedAction(done, next: next)
        }
        disposable?.dispose()
    }

    public func startAndWaitForFailed(_ failed: ((Error) -> Void)? = nil) {
        var disposable: Disposable?
        waitUntil { done in
            disposable = self.startWithFailedAction(done, failed: failed)
        }
        disposable?.dispose()
    }
}

extension SoPersistent.Collection {
    public subscript(section: Int, row: Int) -> Object {
        return self[IndexPath(row: row, section: section)]
    }
}

extension NSManagedObject {
    public func reload() -> Self {
        managedObjectContext!.refresh(self, mergeChanges: true)
        return self
    }
}

public func jsonify(date: Date) -> String {
    return ISO8601SecondFormatter.string(from: date)
}

public func ==<U: Equatable>(a: CollectionUpdate<U>, b: CollectionUpdate<U>) -> Bool {
    switch (a, b) {
    case (.sectionInserted(let a), .sectionInserted(let b)) where a == b: return true
    case (.sectionDeleted(let a), .sectionDeleted(let b)) where a == b: return true
    case (.inserted(let a, let pa, _), .inserted(let b, let pb, _)) where a == b && pa == pb: return true
    case (.updated(let a, let pa, _), .updated(let b, let pb, _)) where a == b && pa == pb: return true
    case (.moved(let a, let aa, let pa, _), .moved(let b, let bb, let pb, _)) where a == b && aa == bb && pa == pb: return true
    case (.deleted(let a, let pa, _), .deleted(let b, let pb, _)) where a == b && pa == pb: return true
    default: return false
    }
}

private class TestBundle {}
extension Bundle {
    public static var soAutomated: Bundle { return Bundle(for: TestBundle.self) }
}

// MARK: - Deprecated
public func attempt(_ block: () throws -> Void) {
    try! block()
}

open class UnitTestCase: XCTestCase {}

extension ManagedObjectObserver {
    public func observe(_ object: NSManagedObject, change: ManagedObjectChange, withExpectation expectation: XCTestExpectation) -> Disposable? {
        return signal.observeValues { _change in
            if case change = _change.0, _change.1 == object { expectation.fulfill() }
        }
    }
}

extension XCTestCase {
    public func assertDifference<T: IntegerArithmetic>(_ selector: ()->T, _ difference: T, _ message: String = "", block: () throws -> Void) {
        let before = selector()
        attempt {
            try block()
        }
        let after = selector()
        XCTAssertEqual(difference, after - before, message)
    }
}
