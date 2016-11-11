//
//  DispatcherSpec.swift
//  SoProgressive
//
//  Created by Nathan Armstrong on 10/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import SoProgressive
import Quick
import Nimble
import SoAutomated
import TooLegit
import ReactiveCocoa

import AVFoundation
import WebKit

class Foo {
    let bar = "hey"
    let progressDispatcher = Dispatcher<Progress, String, NSError> { _ in .empty }
}

class DispatcherSpec: QuickSpec {
    override func spec() {
        describe("Dispatcher") {
            var dispatcher: Dispatcher<Int, String, NSError>!

            var executionCount = 0
			var values: [String]!
			var errors: [NSError]!

            var scheduler: TestScheduler!
			let testError = NSError(domain: "DispatcherSpec", code: 1, userInfo: nil)

            beforeEach {
                executionCount = 0
                values = []
                errors = []

                scheduler = TestScheduler()
                dispatcher = Dispatcher { number in
					return SignalProducer { observer, disposable in
						executionCount += 1

						if number % 2 == 0 {
							observer.sendNext("\(number)")
							observer.sendNext("\(number)\(number)")

							scheduler.schedule {
								observer.sendCompleted()
							}
						} else {
							scheduler.schedule {
								observer.sendFailed(testError)
							}
						}
					}
                }

				dispatcher.values.observeNext { values.append($0) }
				dispatcher.errors.observeNext { errors.append($0) }
            }

            it("should dispatch input") {
                var receivedValue: String?

                dispatcher.apply(0)
                    .assumeNoErrors()
                    .startWithNext {
                        receivedValue = $0
                    }

                expect(executionCount) == 1

                expect(receivedValue) == "00"
                expect(values) == ["0", "00"]
                expect(errors) == []
            }

            it("should dispatch errors") {
                var receivedError: NSError?

                dispatcher.apply(1).startWithFailed {
                    receivedError = $0
                }

                expect(executionCount) == 1

                scheduler.run()
                expect(receivedError).toNot(beNil())
                expect(receivedError) == testError

                expect(values) == []
                expect(errors) == [testError]
            }

            it("should dispatch a completed event") {
                var completedEvent: Event<String, NSError>?
                var receivedCompleted: Bool = false

                dispatcher.events
                    .assumeNoErrors()
                    .observeNext {
                        if case .Completed = $0 {
                            completedEvent = $0
                        }
                    }

                dispatcher.apply(0)
                    .assumeNoErrors()
                    .startWithCompleted {
                        receivedCompleted = true
                    }

                expect(executionCount) == 1

                scheduler.run()

                expect(completedEvent).toNot(beNil())
                expect(receivedCompleted) == true
            }
        }
    }
}
