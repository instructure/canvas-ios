//
//  ColorfulViewModel.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import TooLegit


extension Enrollment {
    public class ViewModel {
        public let enrollment: MutableProperty<Enrollment?>
        public init(enrollment: Enrollment?) {
            self.enrollment = MutableProperty(enrollment)
        }
    }
}