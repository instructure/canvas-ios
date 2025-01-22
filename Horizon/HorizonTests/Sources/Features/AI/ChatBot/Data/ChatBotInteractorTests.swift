//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Quick
import Nimble
@testable import Core
@testable import Horizon

class HorizonTests: QuickSpec {

    class MockDataTask: DataTaskProtocol {
        func data(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) {
            let jsonString = request.url?.absoluteString.contains("canvas.test") == true ? "{\"token\": \"asdf\"}" : "{\"data\": {\"answerPrompt\": \"This is just a test response\"}}"
            let data = jsonString.data(using: .utf8)
            let httpUrlResponse = HTTPURLResponse(
                url: URL(string: "http://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            completionHandler(data, httpUrlResponse, nil)
        }
    }

    override class func spec() {

        let isLive: Bool = false
        let canvasBaseUrl: String = isLive ? "https://horizon.cd.instructure.com" : "http://canvas.test"
        var result: Result<String, Error>? // This is set in the beforeEach block so that the expect checks can access it
        describe("Given the AIInteractor") {

            context("When the sendPrompt method is called successfully") {
                beforeEach {
                    waitUntil(timeout: .seconds(25)) { done in
                        Task {
                            try? await Task.sleep(nanoseconds: isLive ? 1_000_000_000 : 0) // We have to wait for the access token to get set when running live
                            let canvasAccessToken = AppEnvironment.shared.currentSession?.accessToken ?? "test token"
                            let chatBotInteractor = ChatBotInteractor(
                                canvasBaseUrl: canvasBaseUrl,
                                canvasAccessToken: canvasAccessToken,
                                dataTaskProtocol: isLive ? URLSession.shared : MockDataTask()
                            )
                            result = await chatBotInteractor.send(message: ChatBotMessage(text: "message 2", role: .user))
                            done()
                        }
                    }
                }

                it("Then error should be nil") {
                    expect(result?.error).toEventually(beNil(), timeout: .seconds(25))
                }
                it("Then the result string should not be nil") {
                    expect(result?.value).toEventuallyNot(beNil(), timeout: .seconds(25))
                }
                it("Then the graphql prompt contains \"role\": \"system\"") {
                    expect(result?.value).toEventually(contain("\"role\": \"system\""), timeout: .seconds(25))
                }
                it("Then the graphql prompt contains \"text\":\"message 1\"") {
                    expect(result?.value).toEventually(contain("\"text\":\"message 1\""), timeout: .seconds(25))
                }
            }
        }
    }
}
