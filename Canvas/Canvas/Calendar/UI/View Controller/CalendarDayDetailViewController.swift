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

open class CalendarDayDetailViewController: UIViewController, CalendarDayPageViewControllerDelegate, CalendarWeekPageViewControllerDelegate {
    
    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    fileprivate var session: Session!
    
    internal var calendar: Calendar = Calendar.current
    internal var date: Date! {
        didSet {
            updateDay()
        }
    }
    
    // Date Formatters
    internal var dateFormatter = DateFormatter()
    internal var backTitleDateFormatter = DateFormatter()
    
    // IBOutlets
    internal var dateLabel: UILabel!
    internal var prevDayButton: UIButton!
    internal var nextDayButton: UIButton!
    
    // View Controllers
    open var dayPageViewController: CalendarDayPageViewController!
    open var weekPageViewController: CalendarWeekPageViewController!
    fileprivate var prevInteractivePopDelegate: Any!
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------   
    internal var routeToURL: RouteToURL!
    internal var colorForContextID: ColorForContextID!
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------    
    open static func new(_ session: Session, date: Date, canvasContextIDs: [String], routeToURL: @escaping RouteToURL, colorForContextID: @escaping ColorForContextID) -> CalendarDayDetailViewController {
        let controller = CalendarDayDetailViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.date = date
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        
        return controller
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor

        dateFormatter.calendar = calendar
        backTitleDateFormatter.calendar = calendar
        
        // Instance Variables
        dateFormatter.dateStyle = .long
        backTitleDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM", options: 0, locale: Locale.current)
        
        initChildViewControllers()
        initPreviousNextDayButtons()
        initDateLabel()
        initNavigationItemButtons()
        
        layoutViews()
        updateDay()
    }

    // ---------------------------------------------
    // MARK: - UI Init
    // ---------------------------------------------
    func initPreviousNextDayButtons() {
        prevDayButton = UIButton(type: UIButtonType.custom)
        prevDayButton.translatesAutoresizingMaskIntoConstraints = false
        prevDayButton.tintColor = UIColor.calendarTintColor
        prevDayButton.setImage(UIImage(named: "icon_arrow_left", in: CalendarDayDetailViewController.bundle, compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate) , for: UIControlState())
        prevDayButton.addTarget(self, action: #selector(CalendarDayDetailViewController.prevDayPressed(_:)), for: UIControlEvents.touchUpInside)
        
        prevDayButton.accessibilityIdentifier = "prev_day_button"
        prevDayButton.accessibilityLabel = NSLocalizedString("Previous Day", comment: "Button to navigate to the previous day on the calendar")
        view.addSubview(prevDayButton)
        
        nextDayButton = UIButton(type: UIButtonType.custom)
        nextDayButton.translatesAutoresizingMaskIntoConstraints = false
        nextDayButton.tintColor = UIColor.calendarTintColor
        nextDayButton.setImage(UIImage(named: "icon_arrow_right", in: CalendarDayDetailViewController.bundle, compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate) , for: UIControlState())
        nextDayButton.addTarget(self, action: #selector(CalendarDayDetailViewController.nextDayPressed(_:)), for: UIControlEvents.touchUpInside)
        nextDayButton.accessibilityIdentifier = "next_day_button"
        nextDayButton.accessibilityLabel = NSLocalizedString("Next Day", comment: "Button to navigate to the next day on the calendar")
        view.addSubview(nextDayButton)
        
    }
    
    func initNavigationItemButtons() {
        var navigationButtons = [UIBarButtonItem]()
        if let todayView = IconTodayView.instantiateFromNib(Date(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarDayDetailViewController.todayButtonPressed(_:))) {
            todayView.translatesAutoresizingMaskIntoConstraints = true
            todayView.autoresizingMask = UIViewAutoresizing()
            let todayButton = UIBarButtonItem(customView: todayView)
            navigationButtons.append(todayButton)
        }
        
        navigationItem.rightBarButtonItems = navigationButtons
    }
    
    func initDateLabel() {
        dateLabel = UILabel(frame: CGRect.zero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.font = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(20.0)
        view.addSubview(dateLabel)
    }
    
    func initChildViewControllers() {
        dayPageViewController = CalendarDayPageViewController.new(session, date: date, delegate: self, routeToURL: routeToURL, colorForContextID: colorForContextID)
        
        dayPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(dayPageViewController)
        view.addSubview(dayPageViewController.view)
        dayPageViewController.didMove(toParentViewController: self)
        
        weekPageViewController = CalendarWeekPageViewController(calendar: calendar, day: date, delegate: self)
        weekPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(weekPageViewController)
        view.addSubview(weekPageViewController.view)
        weekPageViewController.didMove(toParentViewController: self)
    }
    
    func layoutViews() {
        // weekPaging on top
        let weekPageVerticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-topPadding-[weekPageView(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 40], views: ["topLayoutGuide": topLayoutGuide, "weekPageView": weekPageViewController.view])
        let weekPageHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[weekPageView]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "leftPadding": 0], views: ["weekPageView": weekPageViewController.view])
        view.addConstraints(weekPageVerticalContraints)
        view.addConstraints(weekPageHorizontalContraints)
        
        // day buttons with label in the middle
        let prevDayVerticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-topPadding-[prevDayButton(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 60], views: ["topView": weekPageViewController.view, "prevDayButton": prevDayButton])
        let prevDayHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[prevDayButton(width)]", options: NSLayoutFormatOptions(), metrics: ["leftPadding": 0, "width": 60], views: ["prevDayButton": prevDayButton])
        view.addConstraints(prevDayVerticalContraints)
        view.addConstraints(prevDayHorizontalContraints)
        
        let nextDayVerticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-topPadding-[nextDayButton(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 60], views: ["topView": weekPageViewController.view, "nextDayButton": nextDayButton])
        let nextDayHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[nextDayButton(width)]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "width": 60], views: ["nextDayButton": nextDayButton])
        view.addConstraints(nextDayVerticalContraints)
        view.addConstraints(nextDayHorizontalContraints)
        
        
        let constraint = NSLayoutConstraint(item: dateLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: prevDayButton, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        let dateLabelHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[prevDayButton]-[dateLabel]-[nextDayButton]", options: NSLayoutFormatOptions(), metrics: nil, views: ["prevDayButton": prevDayButton, "dateLabel": dateLabel, "nextDayButton": nextDayButton])
        view.addConstraints([constraint])
        view.addConstraints(dateLabelHorizontalContraints)
        
        // dayPagination on bottom \o/
        let dayPageVerticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topView]-topPadding-[dayPageView]-|", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0], views: ["topView": nextDayButton, "dayPageView": dayPageViewController.view])
        let dayPageHorizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftPadding-[dayPageView]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "leftPadding": 0], views: ["dayPageView": dayPageViewController.view])
        view.addConstraints(dayPageVerticalContraints)
        view.addConstraints(dayPageHorizontalContraints)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction open func todayButtonPressed(_ sender: UIBarButtonItem) {
        let today = Date().startOfDay(calendar)
        dayPageViewController.transitionToDay(today)
        date = today
        weekPageViewController.setDay(today, animated: true)
    }
    
    @IBAction open func calendarsButtonPressed(_ sender: UIBarButtonItem) {
        print("Implement calendarsButtonPressed in subclass to overwrite")
    }
    
    @IBAction func prevDayPressed(_ sender: UIButton) {
        dayPageViewController.transitionToPreviousDay()
        date = dayPageViewController.date as Date!
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    @IBAction func nextDayPressed(_ sender: UIButton) {
        dayPageViewController.transitionToNextDay()
        date = dayPageViewController.date
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    // ---------------------------------------------
    // MARK: - CalendarDayPageViewControllerDelegate
    // ---------------------------------------------
    open func dayPageViewController(_ calendarDayPageViewController: CalendarDayPageViewController, willTransitionToDay day: Date) {
        weekPageViewController.view.isUserInteractionEnabled = false
    }
    
    open func dayPageViewController(_ calendarDayPageViewController: CalendarDayPageViewController, didFinishAnimating finished: Bool, toDay date: Date, transitionCompleted completed: Bool) {
        weekPageViewController.view.isUserInteractionEnabled = true
        if !completed {
            return
        }
        
        let compareDates = date.compare(self.date)
        if compareDates == .orderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        self.date = date
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    // ---------------------------------------------
    // MARK: - CalendarWeekPageViewControllerDelegate
    // ---------------------------------------------
    open func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, willTransitionToDay day: Date) {
        dayPageViewController.view.isUserInteractionEnabled = false
    }
    
    open func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, didFinishAnimating finished: Bool, toDay date: Date, transitionCompleted completed: Bool) {
        dayPageViewController.view.isUserInteractionEnabled = true
        if !completed {
            return
        }
        
        let compareDates = date.compare(self.date)
        if compareDates == .orderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        if compareDates == .orderedAscending {
            dayPageViewController.transitionToPrevWeek()
        } else {
            dayPageViewController.transitionToNextWeek()
        }
        
        self.date = date
    }
    
    open func weekPageViewController(_ calendarWeekPageViewController: CalendarWeekPageViewController, daySelected date: Date) {
        let compareDates = date.compare(self.date)
        if compareDates == .orderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        dayPageViewController.transitionToDay(date)
        self.date = date
    }
    
    // ---------------------------------------------
    // MARK: UI Updates
    // ---------------------------------------------
    fileprivate func updateDay() {
        if let dateLabel = self.dateLabel {
            dateLabel.text = dateFormatter.string(from: date)
            if let rootVC = self.navigationController?.viewControllers[0] {
                rootVC.navigationItem.backBarButtonItem = UIBarButtonItem(title: backTitleDateFormatter.string(from: date), style: .plain, target: nil, action: nil)
            }
        }
    }
}
