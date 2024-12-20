//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import CoreData

public class Grade: NSManagedObject {
    @NSManaged public var gradingPeriodID: String?
    @NSManaged public var enrollment: Enrollment?

    @NSManaged public var currentGrade: String?
    @NSManaged var currentScoreRaw: NSNumber?
    public var currentScore: Double? {
        get { currentScoreRaw?.doubleValue }
        set { currentScoreRaw = NSNumber(value: newValue) }
    }

    @NSManaged public var finalGrade: String?
    @NSManaged var finalScoreRaw: NSNumber?
    public var finalScore: Double? {
        get { finalScoreRaw?.doubleValue }
        set { finalScoreRaw = NSNumber(value: newValue) }
    }

    @NSManaged public var overrideGrade: String?
    @NSManaged var overrideScoreRaw: NSNumber?
    public var overrideScore: Double? {
        get { return overrideScoreRaw?.doubleValue }
        set { overrideScoreRaw = NSNumber(value: newValue) }
    }

    @NSManaged public var unpostedCurrentGrade: String?
    @NSManaged var unpostedCurrentScoreRaw: NSNumber?
    public var unpostedCurrentScore: Double? {
        get { return unpostedCurrentScoreRaw?.doubleValue }
        set { unpostedCurrentScoreRaw = NSNumber(value: newValue) }
    }

}
