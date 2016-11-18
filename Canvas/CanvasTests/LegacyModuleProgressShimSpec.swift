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

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TooLegit
import TechDebt
import CanvasKit
import SoProgressive
import ReactiveCocoa

class LegacyModuleProgressShimSpec: QuickSpec {
    override func spec() {
        describe("LegacyModuleProgressShim") {
            it("should dispatch CBIModuleItemProgressUpdatedNotifications") {
                let session = Session.user1
                LegacyModuleProgressShim.observeProgress(session)
                var disposable: Disposable?

                waitUntil { done in
                    disposable = session.progressDispatcher.onProgress.observeNext { progress in
                        if progress.itemID == "1" && progress.kind == .Viewed && progress.itemType == .LegacyModuleProgressShim {
                            done()
                        }
                    }
                    CBIPostModuleItemProgressUpdate("1", CKIModuleItemCompletionRequirementMustView)
                }

                disposable?.dispose()
            }
        }
    }
}
