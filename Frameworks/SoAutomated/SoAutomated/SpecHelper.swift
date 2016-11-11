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
    
    

import Nimble
import DVR
import TooLegit
import SoPersistent
import ReactiveCocoa
import CoreData
import Quick
import Result

public let DefaultNetworkTimeout: NSTimeInterval = 5

extension Refresher {
    public func refreshAndWait(timeout: NSTimeInterval = 1) {
        waitUntil(timeout: timeout) { done in
            self.refreshingCompleted.observeNext { error in
                expect(error).to(beNil())
                done()
            }
            self.refresh(true)
        }
    }

    public func playback(name: String, in bundle: NSBundle, with session: TooLegit.Session, timeout: NSTimeInterval = 1) {
        session.playback(name, in: bundle) {
            refreshAndWait(timeout)
        }
    }
}

extension TooLegit.Session {
    public func playback(name: String, in bundle: NSBundle, @noescape block: ()->Void) {
        let URLSession = self.URLSession

        // remove User-Agent header temporarily because it varies from target to target
        let userAgent = URLSession.configuration.HTTPAdditionalHeaders?["User-Agent"]
        URLSession.configuration.HTTPAdditionalHeaders?.removeValueForKey("User-Agent")

        let DVRSession = DVR.Session(outputDirectory: "~/Desktop/", cassetteName: name, testBundle: bundle, backingSession: URLSession)
        self.URLSession = DVRSession
        DVRSession.beginRecording()
        block()
        DVRSession.endRecording()
        
        self.URLSession = URLSession
        self.URLSession.configuration.HTTPAdditionalHeaders?["User-Agent"] = userAgent
    }
}

// MARK: - RAC+SoAutomated

public enum TestError: Int {
	case Default = 0
	case Error1 = 1
	case Error2 = 2
}

extension TestError: ErrorType {
}

extension SignalProducerType {
	/// Halts if an error is emitted in the receiver signal.
	/// This is useful in tests to be able to just use `startWithNext`
	/// in cases where we know that an error won't be emitted.
	public func assumeNoErrors() -> SignalProducer<Value, NoError> {
		return self.lift { $0.assumeNoErrors() }
	}
}

extension SignalType {
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

extension SignalProducerType {
    public func startWithCompletedAction(doneAction: () -> Void, file: StaticString = #file, line: UInt = #line, next: ((Value) -> Void)? = nil) -> Disposable {
        return start { event in
            switch event {
            case .Next(let v): next?(v)
            case .Completed: doneAction()
            case .Interrupted: XCTFail("interrupted", file: file, line: line)
            case .Failed(let error): XCTFail("failed \(error)")
            }
        }
    }

    public func startWithFailedAction(doneAction: () -> Void, file: StaticString = #file, line: UInt = #line, failed: ((Error) -> Void)? = nil) -> Disposable {
        return start { event in
            switch event {
            case .Next, .Completed: break
            case .Interrupted: XCTFail("interrupted", file: file, line: line)
            case .Failed(let error):
                failed?(error)
                doneAction()
            }
        }
    }

    public func startAndWaitForCompleted(next: ((Value) -> Void)? = nil) {
        var disposable: Disposable?
        waitUntil { done in
            disposable = self.startWithCompletedAction(done, next: next)
        }
        disposable?.dispose()
    }

    public func startAndWaitForFailed(failed: ((Error) -> Void)? = nil) {
        var disposable: Disposable?
        waitUntil { done in
            disposable = self.startWithFailedAction(done, failed: failed)
        }
        disposable?.dispose()
    }
}

extension Collection {
    public subscript(section: Int, row: Int) -> Object {
        return self[NSIndexPath(forRow: row, inSection: section)]
    }
}

extension NSManagedObject {
    public func reload() -> Self {
        managedObjectContext!.refreshObject(self, mergeChanges: true)
        return self
    }
}

public func jsonify(date date: NSDate) -> String {
    return ISO8601SecondFormatter.stringFromDate(date)
}

public func ==<U: Equatable>(a: CollectionUpdate<U>, b: CollectionUpdate<U>) -> Bool {
    switch (a, b) {
    case (.SectionInserted(let a), .SectionInserted(let b)) where a == b: return true
    case (.SectionDeleted(let a), .SectionDeleted(let b)) where a == b: return true
    case (.Inserted(let a, let pa), .Inserted(let b, let pb)) where a == b && pa == pb: return true
    case (.Updated(let a, let pa), .Updated(let b, let pb)) where a == b && pa == pb: return true
    case (.Moved(let a, let aa, let pa), .Moved(let b, let bb, let pb)) where a == b && aa == bb && pa == pb: return true
    case (.Deleted(let a, let pa), .Deleted(let b, let pb)) where a == b && pa == pb: return true
    default: return false
    }
}

private class Bundle {}
extension NSBundle {
    public static var soAutomated: NSBundle { return NSBundle(forClass: Bundle.self) }
}

// MARK: - Deprecated
public func attempt(@noescape block: () throws -> Void) {
    try! block()
}

public class UnitTestCase: XCTestCase {}

extension ManagedObjectObserver {
    public func observe(object: NSManagedObject, change: ManagedObjectChange, withExpectation expectation: XCTestExpectation) -> Disposable? {
        return signal.observeNext { _change in
            if case change = _change.0 where _change.1 == object { expectation.fulfill() }
        }
    }
}

extension XCTestCase {
    public func assertDifference<T: IntegerArithmeticType>(@noescape selector: ()->T, _ difference: T, _ message: String = "", @noescape block: () throws -> Void) {
        let before = selector()
        attempt {
            try block()
        }
        let after = selector()
        XCTAssertEqual(difference, after - before, message)
    }
}
