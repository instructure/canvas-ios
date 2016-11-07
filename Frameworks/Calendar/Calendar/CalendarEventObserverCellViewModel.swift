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
    
    

import CalendarKit
import SoPersistent
import TooLegit

struct CalendarEventObserveeCellViewModel: TableViewCellViewModel {
    static var subtitleDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()

    static let reuseIdentifier = "CalendarEventCell"
    static let nibName = "CalendarEventCell"

    let name: String
    let hasSubmitted: Bool
    let currentGrade: String?
    let submissionLate: Bool
    let submissionExcused: Bool
    let dueAt: NSDate

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: CalendarEventViewModel.nibName, bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: CalendarEventViewModel.reuseIdentifier)
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CalendarEventViewModel.reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = detailText()
        cell.detailTextLabel?.textColor = detailColor()

        return cell
    }

    init(calendarEvent: CalendarEvent) {
        name = calendarEvent.title!
        currentGrade = calendarEvent.currentGrade
        hasSubmitted = calendarEvent.hasSubmitted
        submissionLate = calendarEvent.submissionLate
        submissionExcused = calendarEvent.submissionExcused
        dueAt = calendarEvent.endAt ?? NSDate()
    }

    func detailText() -> String {
        if submissionExcused {
            return "\(NSLocalizedString("Excused", comment: ""))"
        }

        if let grade = currentGrade {
            if submissionLate {
                return "\(NSLocalizedString("Late: ", comment: "")) \(grade)"
            } else {
                return "\(NSLocalizedString("Graded: ", comment: "")) \(grade)"
            }
        } else if hasSubmitted {
            if submissionLate {
                return "\(NSLocalizedString("Late", comment: ""))"
            } else {
                return "\(NSLocalizedString("Submitted", comment: ""))"
            }
        } else {
            if NSDate().compare(dueAt) == NSComparisonResult.OrderedDescending {
                return "\(NSLocalizedString("Missing", comment: ""))"
            } else {
                return ""
            }
        }
    }

    func detailColor() -> UIColor {
        if submissionLate {
            return UIColor.yellowColor()
        }
        if currentGrade != nil || hasSubmitted || submissionExcused {
            return UIColor.blueColor()
        }

        if NSDate().compare(dueAt) == NSComparisonResult.OrderedDescending {
            return UIColor.redColor()
        }

        return UIColor.blueColor()
    }
}