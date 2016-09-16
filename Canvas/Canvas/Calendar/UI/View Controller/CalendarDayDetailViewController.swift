//
//  CalendarDetailViewController.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/10/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit

public class CalendarDayDetailViewController: UIViewController, CalendarDayPageViewControllerDelegate, CalendarWeekPageViewControllerDelegate {
    
    // ---------------------------------------------
    // MARK: - Private Variables
    // ---------------------------------------------
    private var session: Session!
    
    internal var calendar: NSCalendar = NSCalendar.currentCalendar()
    internal var date: NSDate! {
        didSet {
            updateDay()
        }
    }
    
    // Date Formatters
    internal var dateFormatter = NSDateFormatter()
    internal var backTitleDateFormatter = NSDateFormatter()
    
    // IBOutlets
    internal var dateLabel: UILabel!
    internal var prevDayButton: UIButton!
    internal var nextDayButton: UIButton!
    
    // View Controllers
    public var dayPageViewController: CalendarDayPageViewController!
    public var weekPageViewController: CalendarWeekPageViewController!
    private var prevInteractivePopDelegate: AnyObject!
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------   
    internal var routeToURL: RouteToURL!
    internal var colorForContextID: ColorForContextID!
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------    
    public static func new(session: Session, date: NSDate, canvasContextIDs: [String], routeToURL: RouteToURL, colorForContextID: ColorForContextID) -> CalendarDayDetailViewController {
        let controller = CalendarDayDetailViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.date = date
        controller.routeToURL = routeToURL
        controller.colorForContextID = colorForContextID
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor

        dateFormatter.calendar = calendar
        backTitleDateFormatter.calendar = calendar
        
        // Instance Variables
        dateFormatter.dateStyle = .LongStyle
        backTitleDateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMM", options: 0, locale: NSLocale.currentLocale())
        
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
        prevDayButton = UIButton(type: UIButtonType.Custom)
        prevDayButton.translatesAutoresizingMaskIntoConstraints = false
        prevDayButton.tintColor = UIColor.calendarTintColor
        prevDayButton.setImage(UIImage(named: "icon_arrow_left", inBundle: CalendarDayDetailViewController.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) , forState: .Normal)
        prevDayButton.addTarget(self, action: #selector(CalendarDayDetailViewController.prevDayPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(prevDayButton)
        
        nextDayButton = UIButton(type: UIButtonType.Custom)
        nextDayButton.translatesAutoresizingMaskIntoConstraints = false
        nextDayButton.tintColor = UIColor.calendarTintColor
        nextDayButton.setImage(UIImage(named: "icon_arrow_right", inBundle: CalendarDayDetailViewController.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) , forState: .Normal)
        nextDayButton.addTarget(self, action: #selector(CalendarDayDetailViewController.nextDayPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(nextDayButton)
        
    }
    
    func initNavigationItemButtons() {
        var navigationButtons = [UIBarButtonItem]()
        if let todayView = IconTodayView.instantiateFromNib(NSDate(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarDayDetailViewController.todayButtonPressed(_:))) {
            todayView.translatesAutoresizingMaskIntoConstraints = true
            todayView.autoresizingMask = UIViewAutoresizing()
            let todayButton = UIBarButtonItem(customView: todayView)
            navigationButtons.append(todayButton)
        }
        
        navigationItem.rightBarButtonItems = navigationButtons
    }
    
    func initDateLabel() {
        dateLabel = UILabel(frame: CGRectZero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(dateLabel)
    }
    
    func initChildViewControllers() {
        dayPageViewController = CalendarDayPageViewController.new(session, date: date, delegate: self, routeToURL: routeToURL, colorForContextID: colorForContextID)
        
        dayPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(dayPageViewController)
        view.addSubview(dayPageViewController.view)
        dayPageViewController.didMoveToParentViewController(self)
        
        
        weekPageViewController = CalendarWeekPageViewController(calendar: calendar, day: date, delegate: self)
        weekPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(weekPageViewController)
        view.addSubview(weekPageViewController.view)
        weekPageViewController.didMoveToParentViewController(self)
    }
    
    func layoutViews() {
        // weekPaging on top
        let weekPageVerticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-topPadding-[weekPageView(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 40], views: ["topLayoutGuide": topLayoutGuide, "weekPageView": weekPageViewController.view])
        let weekPageHorizontalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftPadding-[weekPageView]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "leftPadding": 0], views: ["weekPageView": weekPageViewController.view])
        view.addConstraints(weekPageVerticalContraints)
        view.addConstraints(weekPageHorizontalContraints)
        
        // day buttons with label in the middle
        let prevDayVerticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topView]-topPadding-[prevDayButton(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 60], views: ["topView": weekPageViewController.view, "prevDayButton": prevDayButton])
        let prevDayHorizontalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftPadding-[prevDayButton(width)]", options: NSLayoutFormatOptions(), metrics: ["leftPadding": 0, "width": 60], views: ["prevDayButton": prevDayButton])
        view.addConstraints(prevDayVerticalContraints)
        view.addConstraints(prevDayHorizontalContraints)
        
        let nextDayVerticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topView]-topPadding-[nextDayButton(height)]", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0, "height": 60], views: ["topView": weekPageViewController.view, "nextDayButton": nextDayButton])
        let nextDayHorizontalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[nextDayButton(width)]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "width": 60], views: ["nextDayButton": nextDayButton])
        view.addConstraints(nextDayVerticalContraints)
        view.addConstraints(nextDayHorizontalContraints)
        
        
        let constraint = NSLayoutConstraint(item: dateLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: prevDayButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        let dateLabelHorizontalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[prevDayButton]-[dateLabel]-[nextDayButton]", options: NSLayoutFormatOptions(), metrics: nil, views: ["prevDayButton": prevDayButton, "dateLabel": dateLabel, "nextDayButton": nextDayButton])
        view.addConstraints([constraint])
        view.addConstraints(dateLabelHorizontalContraints)
        
        // dayPagination on bottom \o/
        let dayPageVerticalContraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topView]-topPadding-[dayPageView]-|", options: NSLayoutFormatOptions(), metrics: ["topPadding": 0], views: ["topView": nextDayButton, "dayPageView": dayPageViewController.view])
        let dayPageHorizontalContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftPadding-[dayPageView]-rightPadding-|", options: NSLayoutFormatOptions(), metrics: ["rightPadding": 0, "leftPadding": 0], views: ["dayPageView": dayPageViewController.view])
        view.addConstraints(dayPageVerticalContraints)
        view.addConstraints(dayPageHorizontalContraints)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction public func todayButtonPressed(sender: UIBarButtonItem) {
        let today = NSDate().startOfDay(calendar)
        dayPageViewController.transitionToDay(today)
        date = today
        weekPageViewController.setDay(today, animated: true)
    }
    
    @IBAction public func calendarsButtonPressed(sender: UIBarButtonItem) {
        print("Implement calendarsButtonPressed in subclass to overwrite")
    }
    
    @IBAction func prevDayPressed(sender: UIButton) {
        dayPageViewController.transitionToPreviousDay()
        date = dayPageViewController.date
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    @IBAction func nextDayPressed(sender: UIButton) {
        dayPageViewController.transitionToNextDay()
        date = dayPageViewController.date
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    // ---------------------------------------------
    // MARK: - CalendarDayPageViewControllerDelegate
    // ---------------------------------------------
    public func dayPageViewController(calendarDayPageViewController: CalendarDayPageViewController, willTransitionToDay day: NSDate) {
        weekPageViewController.view.userInteractionEnabled = false
    }
    
    public func dayPageViewController(calendarDayPageViewController: CalendarDayPageViewController, didFinishAnimating finished: Bool, toDay date: NSDate, transitionCompleted completed: Bool) {
        weekPageViewController.view.userInteractionEnabled = true
        if !completed {
            return
        }
        
        let compareDates = date.compare(self.date)
        if compareDates == .OrderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        self.date = date
        self.weekPageViewController.setDay(date, animated: true)
    }
    
    // ---------------------------------------------
    // MARK: - CalendarWeekPageViewControllerDelegate
    // ---------------------------------------------
    public func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, willTransitionToDay day: NSDate) {
        dayPageViewController.view.userInteractionEnabled = false
    }
    
    public func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, didFinishAnimating finished: Bool, toDay date: NSDate, transitionCompleted completed: Bool) {
        dayPageViewController.view.userInteractionEnabled = true
        if !completed {
            return
        }
        
        let compareDates = date.compare(self.date)
        if compareDates == .OrderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        if compareDates == .OrderedAscending {
            dayPageViewController.transitionToPrevWeek()
        } else {
            dayPageViewController.transitionToNextWeek()
        }
        
        self.date = date
    }
    
    public func weekPageViewController(calendarWeekPageViewController: CalendarWeekPageViewController, daySelected date: NSDate) {
        let compareDates = date.compare(self.date)
        if compareDates == .OrderedSame {
            // Dates are equal, no change is needed
            return
        }
        
        dayPageViewController.transitionToDay(date)
        self.date = date
    }
    
    // ---------------------------------------------
    // MARK: UI Updates
    // ---------------------------------------------
    private func updateDay() {
        if let dateLabel = self.dateLabel {
            dateLabel.text = dateFormatter.stringFromDate(date)
            if let rootVC = self.navigationController?.viewControllers[0] {
                rootVC.title = backTitleDateFormatter.stringFromDate(date)
            }
        }
    }
}