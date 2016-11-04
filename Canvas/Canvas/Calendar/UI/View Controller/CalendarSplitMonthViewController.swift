
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
import TooLegit

public class CalendarSplitMonthViewController: UIViewController {
    
    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // External Closures
    public var dateSelected: DateSelected!
    public var routeToURL: RouteToURL!
    public var colorForContextID: ColorForContextID!
    private var session: Session!
    
    private lazy var todayButtonAction: UIBarButtonItemAction = {
        return { url in
            self.monthViewController.calendarView?.scrollToToday(true)
        }
        }()
    
    // Views
    @IBOutlet weak var lblDayOfMonth: UILabel!
    @IBOutlet weak var lblMonthName: UILabel!
    @IBOutlet weak var lblDayOfWeek: UILabel!
    @IBOutlet weak var monthContainerView: UIView!
    @IBOutlet weak var dateView: UIView!
    
    // View Controllers
    private var monthViewController: CalendarMonthViewController!
    private var dayListViewController: CalendarDayListViewController!
    private var dayListHolder: UIView!
    
    
    
    // Date Formatters
    private var monthDateFormatter = NSDateFormatter()
    private var dayOfWeekDateFormatter = NSDateFormatter()
    private var dayOfMonthDateFormatter = NSDateFormatter()
    
    private var date = NSDate()
    
    // Default Closures
    private lazy var defaultDateSelected: DateSelected = {
        return { date in
            self.date = date
            self.buildListForDate()
            self.setDay(date)
        }
        }()
    
    private lazy var defaultRouteToURL: RouteToURL = {
        return { url in
            print("DEFAULT: routeToURL: \(url)")
        }
        }()
    
    private lazy var defaultColorForContextID: ColorForContextID = {
        return { id in
            return UIColor.redColor()
        }
        }()
    
    // Segue IDs
    let EmbedDayListSegueID = "EmbedDayListSegueID"
    let EmbedMonthSegueID = "EmbedMonthSegueID"
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    public static func new(session: Session, dateSelected: DateSelected? = nil, colorForContextID: ColorForContextID? = nil, routeToURL: RouteToURL? = nil) -> CalendarSplitMonthViewController {
        let controller = UIStoryboard(name: "CalendarSplitMonthViewController", bundle: CalendarSplitMonthViewController.bundle).instantiateInitialViewController() as! CalendarSplitMonthViewController
        controller.session = session
        
        // Date Setters
        controller.date = NSDate()
        controller.monthDateFormatter.dateFormat = "MMMM"
        controller.dayOfWeekDateFormatter.dateFormat = "EEEE"
        controller.dayOfMonthDateFormatter.dateFormat = "d"
        
        controller.dateSelected = dateSelected ?? controller.defaultDateSelected
        controller.routeToURL = routeToURL ?? controller.defaultRouteToURL
        controller.colorForContextID = colorForContextID ?? controller.defaultColorForContextID
        
        
        controller.monthViewController = CalendarMonthViewController.new(session, dateSelected: dateSelected, colorForContextID: colorForContextID, routeToURL: routeToURL)
        controller.addChildViewController(controller.monthViewController)
        
        controller.monthViewController.dateSelected = controller.dateSelected
        controller.monthViewController.didFinishRefreshing = { [weak controller] in
            controller?.dayListViewController.reloadData()
        }
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calendar"
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor
        
        // TODO: Nate Pin the View Controllers (Day/List) to correct positions with NSConstraints
        setupViewControllers()
        buildListForDate()
        initNavigationButtons()
        reloadView(date)
    }
    
    private func setupViewControllers() {
        let monthView = monthViewController.view
        dayListHolder = UIView()
        let views: [String: AnyObject] = ["top": topLayoutGuide, "list": monthViewController.view, "day": dayListHolder, "date": dateView];
        monthViewController.view.translatesAutoresizingMaskIntoConstraints = false
        dayListHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthView)
        view.addSubview(dayListHolder)
        dateView.backgroundColor = dayListHolder.backgroundColor
        view.backgroundColor = UIColor.lightGrayColor()
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top][list]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top][date][day]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[list]-1-[day]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: monthViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: dayListHolder, attribute: NSLayoutAttribute.Width, multiplier: 1.5, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: dayListHolder, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: dateView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: dayListHolder, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: dateView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
    }
    
    private func buildListForDate() {
        if let dayListController = dayListViewController {
            dayListController.view.removeFromSuperview()
            dayListController.removeFromParentViewController()
        }
        dayListViewController = CalendarDayListViewController.new(session, date: date, routeToURL: routeToURL, colorForContextID: colorForContextID)
        dateView.backgroundColor = dayListViewController.view.backgroundColor
        dayListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        dayListHolder.addSubview(dayListViewController.view)
        dayListHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[list]", options: NSLayoutFormatOptions(), metrics: nil, views: ["list": dayListViewController.view]))
        view.addConstraint(NSLayoutConstraint(item: dayListViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0))
        dayListHolder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[list]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["list": dayListViewController.view]))
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Scrolling needs to happen after viewDidAppear so we're hiding this until after that happens
        monthViewController?.view.alpha = 0.0
        
        if let view = monthContainerView {
            let layer = view.layer
            layer.masksToBounds = false;
            layer.shadowColor = UIColor.blackColor().CGColor;
            layer.shadowOffset = CGSizeMake(0.0, 0.0);
            layer.shadowOpacity = 0.5;
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll to correct date
        monthViewController.calendarView.selectDate(date)
        monthViewController.calendarView.scrollToDate(date, animated: false)
        
        // Animate the month view visible
        UIView.animateWithDuration(0.10, animations: { () -> Void in
            self.monthViewController.view.alpha = 1.0
        })
    }
    
    // ---------------------------------------------
    // MARK: - UI Methods
    // ---------------------------------------------
    
    private func initNavigationButtons() {
        var navigationButtons = [UIBarButtonItem]()
        // Navigation Buttons
        if let refreshImage = UIImage(named: "icon_sync", inBundle: CalendarMonthViewController.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) {
            let refreshButton = UIBarButtonItem(image: refreshImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CalendarSplitMonthViewController.refreshButtonPressed(_:)))
            refreshButton.accessibilityLabel = NSLocalizedString("Refresh Button", comment: "")
            refreshButton.accessibilityHint = NSLocalizedString("Refreshes the calendar content", comment: "")
            navigationButtons.append(refreshButton)
        }
        
        if let todayView = IconTodayView.instantiateFromNib(NSDate(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarSplitMonthViewController.todayButtonPressed(_:))) {
            todayView.translatesAutoresizingMaskIntoConstraints = true
            todayView.autoresizingMask = UIViewAutoresizing()
            let todayButton = UIBarButtonItem(customView: todayView)
            // it's weird that it had to be done this way but... ¯\_(ツ)_/¯
            todayView.lblDayOfMonth.accessibilityLabel = NSLocalizedString("Today Button", comment: "")
            todayView.lblDayOfMonth.accessibilityHint = NSLocalizedString("Jumps to current day on calendar", comment: "")
            navigationButtons.append(todayButton)
        }
        
        navigationItem.rightBarButtonItems = navigationButtons
    }
    
    // ---------------------------------------------
    // MARK: - UI Updates
    // ---------------------------------------------
    @IBAction func todayButtonPressed(sender: UIBarButtonItem) {
        todayButtonAction(sender: sender)
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        reloadData(true)
    }
    
    private func reloadView(date: NSDate) {
        lblMonthName.text = monthDateFormatter.stringFromDate(date)
        lblDayOfWeek.text = dayOfWeekDateFormatter.stringFromDate(date)
        lblDayOfMonth.text = dayOfMonthDateFormatter.stringFromDate(date)
    }
    
    public func reloadData(forceUpdate: Bool = false) {
        monthViewController?.reloadData(forceUpdate)
        // day list view is reloaded in the completion callback for monthVC?.reloadData()
    }
    
    public func scrollToToday(animated: Bool) {
        monthViewController?.calendarView?.scrollToToday(animated)
    }
    
    private func setDay(date: NSDate) {
        dayListViewController?.day = date
        reloadView(date)
        reloadData()
    }
}

