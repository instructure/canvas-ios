
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
    
    

import CoreData
@testable import EnrollmentKit

extension GradingPeriod {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      title: String = "Period 1",
                      courseID: String = "1",
                      startDate: NSDate = NSDate()
    ) -> GradingPeriod {
        let gradingPeriod = GradingPeriod(inContext: context)
        gradingPeriod.id = id
        gradingPeriod.title = title
        gradingPeriod.courseID = courseID
        gradingPeriod.startDate = startDate
        return gradingPeriod
    }
}
