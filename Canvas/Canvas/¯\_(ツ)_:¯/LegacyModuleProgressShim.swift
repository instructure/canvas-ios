//
//  LegacyModuleProgressShim.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 4/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoProgressive
import TooLegit
import TechDebt

private let MustView = "must_view"
private let MustSubmit = "must_submit"
private let MustContribute = "must_contribute"
private let MinimumScore = "min_score"
private let MustMarkDone = "must_mark_done"

/** Keeps TechDebt Modules and Assignments UI up to date course progress
 */
public class LegacyModuleProgressShim: NSObject {
    public static func observeProgress(session: Session) {
        session.progressDispatcher
            .onProgress
            .observeNext { progress in
                let kind: String
                switch progress.kind {
                case .Viewed: kind = MustView
                case .Contributed: kind = MustContribute
                case .MarkedDone: kind = MustMarkDone
                case .Submitted: kind = MustSubmit
                case .MinimumScore: kind = MinimumScore
                }
                CBIPostModuleItemProgressUpdate(progress.itemID, kind)
            }
    }
}