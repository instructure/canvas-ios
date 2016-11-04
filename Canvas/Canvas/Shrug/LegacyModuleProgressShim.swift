
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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