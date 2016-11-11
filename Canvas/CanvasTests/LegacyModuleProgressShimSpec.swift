//
//  LegacyModuleProgressShimSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 10/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
