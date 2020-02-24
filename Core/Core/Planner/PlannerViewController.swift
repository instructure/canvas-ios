//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit

public class PlannerViewController: UIViewController {

    var calendar: CalendarViewController!
    var plannerList: PlannerListViewController!
    var studentID: String!

    public static func create(studentID: String) -> PlannerViewController {
        let vc = PlannerViewController()
        vc.studentID = studentID
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        calendar = CalendarViewController.create(studentID: studentID)
        plannerList = PlannerListViewController.create(studentID: studentID)
        calendar.delegate = plannerList

        embed(calendar, in: view, constraintHandler: { child, container in
            child.view.pinToLeftAndRightOfSuperview()
            child.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        })

        embed(plannerList, in: view, constraintHandler: { [weak self] child, container in
            guard let ss = self else { return }
            child.view.pinToLeftAndRightOfSuperview()
            NSLayoutConstraint.activate([
                child.view.topAnchor.constraint(equalTo: ss.calendar.daysContainer.bottomAnchor),
                child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
        })
    }
}

extension PlannerListViewController: CalendarViewControllerDelegate {
    func dailyActivityCount(forDate: Date, handler: @escaping (DailyCalendarActivityData?) -> Void) {
        getDailyActivityForMonth(forDate: forDate, handler: handler)
    }

    func selectedDateDidChange(_ date: Date) {
        updateListForDates(start: date.startOfDay(), end: date.endOfDay())
    }
}
