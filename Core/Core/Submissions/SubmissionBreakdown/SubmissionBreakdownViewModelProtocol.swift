//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import SwiftUI

public protocol SubmissionBreakdownViewModelProtocol: ObservableObject {
    var isReady: Bool { get }
    var graded: Int { get }
    var ungraded: Int { get }
    var unsubmitted: Int { get }
    var submissionCount: Int { get }
    var noSubmissionTypes: Bool { get }
    var paperSubmissionTypes: Bool { get }
    var showError: Bool {get set}
    var errorText: String? { get }

    func viewDidAppear()
    func routeToAll(router: Router, viewController: WeakViewController)
    func routeToGraded(router: Router, viewController: WeakViewController)
    func routeToUngraded(router: Router, viewController: WeakViewController)
    func routeToUnsubmitted(router: Router, viewController: WeakViewController)
}

#if DEBUG
// MARK: - Preview Support
/**
Use only for SwiftUI previews.
*/
public class PreviewSubmissionBreakdownViewModel: SubmissionBreakdownViewModelProtocol {
    public var isReady: Bool = true
    public var graded: Int
    public var ungraded: Int
    public var unsubmitted: Int
    public var submissionCount: Int
    public var noSubmissionTypes: Bool = false
    public var paperSubmissionTypes: Bool = false
    public var showError: Bool = false
    public var errorText: String?

    public func viewDidAppear() {}
    public func routeToAll(router: Router, viewController: WeakViewController) {}
    public func routeToGraded(router: Router, viewController: WeakViewController) {}
    public func routeToUngraded(router: Router, viewController: WeakViewController) {}
    public func routeToUnsubmitted(router: Router, viewController: WeakViewController) {}

    public init(graded: Int, ungraded: Int, unsubmitted: Int, submissionCount: Int) {
        self.graded = graded
        self.ungraded = ungraded
        self.unsubmitted = unsubmitted
        self.submissionCount = submissionCount
    }
}
// MARK: Preview Support -
#endif
