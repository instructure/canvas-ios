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
    
    

import UIKit
import CanvasCore

protocol CalendarWeekDayViewControllerDelegate {
    func weekdayViewController(_ weekdayViewController: CalendarWeekDayViewController, selectedDate day: Date)
}

class CalendarWeekDayViewController: UIViewController, CalendarWeekViewDelegate {
    
    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    var calendar: Calendar
    var day: Date
    var delegate: CalendarWeekDayViewControllerDelegate?
    
    // Date Formatters
    var dateFormatter = DateFormatter()
    
    // Data Structure
    var calendarEvents = [CalendarEvent]()
    
    var weekView: CalendarWeekView!
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    init(calendar: Calendar, day: Date, delegate: CalendarWeekDayViewControllerDelegate?) {
        self.calendar = calendar
        self.day = day
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
        
        dateFormatter.dateStyle = .full
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWeekView()
        layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setDay(day, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.weekView.setSelectedDay(nil, animated: true)
    }
    
    func initWeekView() {
        weekView = CalendarWeekView(frame: CGRect.zero)
        weekView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weekView)
        
        weekView.delegate = self
    }
    
    func layoutSubviews() {
        let weekViewVerticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-topPadding-[weekView]-bottomPadding-|", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "bottomPadding": 0], views: ["topLayoutGuide": topLayoutGuide, "weekView": weekView])
        let weekViewHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[weekView]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "leftPadding": 0], views: ["weekView": weekView])
        view.addConstraints(weekViewVerticalContraints)
        view.addConstraints(weekViewHorizontalContraints)
    }
    
    func setSelectedWeekdayIndex(_ index: Int, animated: Bool) {
        self.weekView.setSelectedWeekdayIndex(index, animated: animated)
    }
    
    func setDay(_ day: Date, animated: Bool) {
        self.day = day
        self.weekView.setInitialDay(day, animated: animated)
        self.weekView.setSelectedDay(day, animated: animated)
    }
    
    func dateIsInWeek(_ date: Date) -> Bool {
        let componentsOfDate = (calendar as NSCalendar).components([.year, .weekOfYear], from: date)
        let componentsOfWeek = (calendar as NSCalendar).components([.year, .weekOfYear], from: day)
        return componentsOfDate.weekOfYear == componentsOfWeek.weekOfYear && componentsOfDate.year == componentsOfWeek.year
    }
    
    func weekView(_ weekView: CalendarWeekView, selectedDate day: Date) {
        if let delegate = delegate {
            delegate.weekdayViewController(self, selectedDate: day)
        }
    }
}
