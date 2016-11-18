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
