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
    override class func spec() {
        let aiInteractor = AIInteractor()
        var result: Result<String, Error>?

        describe("Given the AIInteractor") {
            context("When the sendPrompt method is called successfully") {
                beforeEach {
                    waitUntil { done in
                        Task {
                            let accessToken = AppEnvironment.shared.currentSession?.accessToken ?? "1~7RvJ7T9VCrx32EcTcRYeeX8PTRXHVnMZ6e9fBVMaTFzyXxYtUAwEAhfEzPZ3D7fW"
                            result = await aiInteractor.sendPrompt(token: accessToken, prompt: "This is just a test prompt")
                            done()
                        }
                    }
                }

                it("Then error should be nil") {
                    expect(result?.error).to(beNil())
                }
            }
            context("When the sendPrompt method is given an invalid canvas token") {
                beforeEach {
                    waitUntil { done in
                        Task {
                            result = await aiInteractor.sendPrompt(token: "", prompt: "This is just a test prompt")
                            done()
                        }
                    }
                }
                xit("Then an unableToGetCedarToken error should be returned") {
                    expect(result?.error).to(matchError(AIInteractorError.unableToGetCedarToken(httpStatusCode: 401)))
                }
            }
        }
    }
}
