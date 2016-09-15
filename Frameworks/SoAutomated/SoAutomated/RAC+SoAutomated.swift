//
//  RAC+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import ReactiveCocoa

extension SignalProducerType {
    public func startWithStub(stub: Stub, file: StaticString = #file, line: UInt = #line, next: (Value -> Void)? = nil) {
        stub.testCase.performNetworkRequests(with: stub) { expectation in
            self.startWithCompletedAction(expectation) { value in
                next?(value)
            }
        }
    }

    public func startWithCompletedExpectation(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line, next: ((Value) -> Void) = { _ in }) -> Disposable {
        return start { event in
            switch event {
            case .Next(let v): next(v)
            case .Completed: expectation.fulfill()
            case .Interrupted: XCTFail("interrupted", file: file, line: line)
            case .Failed(let error): XCTFail("failed \(error)")
            }
        }
    }

    public func startWithFailedExpectation(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line, failed: ((Error) -> Void) = { _ in }) -> Disposable {
        return start { event in
            switch event {
            case .Failed(let error):
                failed(error)
                expectation.fulfill()
            default: break
            }
        }
    }

    public func startWithCompletedAction(doneAction: DoneAction, file: StaticString = #file, line: UInt = #line, next: ((Value) -> Void)?) -> Disposable {
        return start { event in
            switch event {
            case .Next(let v): next?(v)
            case .Completed: doneAction()
            case .Interrupted: XCTFail("interrupted", file: file, line: line)
            case .Failed(let error): XCTFail("failed \(error)")
            }
        }
    }
}
