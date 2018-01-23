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
import CanvasCore

open class CalendarSplitMonthViewController: UIViewController {
    
    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    // External Closures
    open var dateSelected: DateSelected!
    open var routeToURL: RouteToURL!
    open var colorForContextID: ColorForContextID!
    fileprivate var session: Session!
    
    fileprivate lazy var todayButtonAction: UIBarButtonItemAction = {
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
    fileprivate var monthViewController: CalendarMonthViewController!
    fileprivate var dayListViewController: CalendarDayListViewController!
    fileprivate var dayListHolder: UIView!
    
    
    
    // Date Formatters
    fileprivate var monthDateFormatter = DateFormatter()
    fileprivate var dayOfWeekDateFormatter = DateFormatter()
    fileprivate var dayOfMonthDateFormatter = DateFormatter()
    
    fileprivate var date = Date()
    
    // Default Closures
    fileprivate lazy var defaultDateSelected: DateSelected = {
        return { date in
            self.date = date as Date
            self.buildListForDate()
            self.setDay(date as Date)
        }
        }()
    
    fileprivate lazy var defaultRouteToURL: RouteToURL = {
        return { url in
            print("DEFAULT: routeToURL: \(url)")
        }
        }()
    
    fileprivate lazy var defaultColorForContextID: ColorForContextID = {
        return { id in
            return UIColor.red
        }
        }()
    
    // Segue IDs
    let EmbedDayListSegueID = "EmbedDayListSegueID"
    let EmbedMonthSegueID = "EmbedMonthSegueID"
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    open static func new(_ session: Session, dateSelected: DateSelected? = nil, colorForContextID: ColorForContextID? = nil, routeToURL: RouteToURL? = nil) -> CalendarSplitMonthViewController {
        let controller = UIStoryboard(name: "CalendarSplitMonthViewController", bundle: CalendarSplitMonthViewController.bundle).instantiateInitialViewController() as! CalendarSplitMonthViewController
        controller.session = session
        
        // Date Setters
        controller.date = Date()
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Calendar", comment: "Calendar page title")
        self.view.backgroundColor = UIColor.calendarDayDetailBackgroundColor
        
        // TODO: Nate Pin the View Controllers (Day/List) to correct positions with NSConstraints
        setupViewControllers()
        buildListForDate()
        initNavigationButtons()
        reloadView(date)
    }
    
    fileprivate func setupViewControllers() {
        let monthView = monthViewController.view
        dayListHolder = UIView()
        let views: [String: Any] = ["top": topLayoutGuide, "list": monthViewController.view, "day": dayListHolder, "date": dateView];
        monthViewController.view.translatesAutoresizingMaskIntoConstraints = false
        dayListHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthView!)
        view.addSubview(dayListHolder)
        dateView.backgroundColor = dayListHolder.backgroundColor
        view.backgroundColor = .lightGray
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][list]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][date][day]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[list]-1-[day]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: monthViewController.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: dayListHolder, attribute: NSLayoutAttribute.width, multiplier: 1.5, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: dayListHolder, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: dateView, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: dayListHolder, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: dateView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0))
    }
    
    fileprivate func buildListForDate() {
        if let dayListController = dayListViewController {
            dayListController.view.removeFromSuperview()
            dayListController.removeFromParentViewController()
        }
        dayListViewController = CalendarDayListViewController.new(session, date: date, routeToURL: routeToURL, colorForContextID: colorForContextID)
        dateView.backgroundColor = dayListViewController.view.backgroundColor
        dayListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        dayListHolder.addSubview(dayListViewController.view)
        dayListHolder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[list]", options: NSLayoutFormatOptions(), metrics: nil, views: ["list": dayListViewController.view]))
        view.addConstraint(NSLayoutConstraint(item: dayListViewController.view, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        dayListHolder.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[list]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["list": dayListViewController.view]))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Scrolling needs to happen after viewDidAppear so we're hiding this until after that happens
        monthViewController?.view.alpha = 0.0
        
        if let view = monthContainerView {
            let layer = view.layer
            layer.masksToBounds = false;
            layer.shadowColor = UIColor.black.cgColor;
            layer.shadowOffset = .zero;
            layer.shadowOpacity = 0.5;
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll to correct date
        monthViewController.calendarView.selectDate(date)
        monthViewController.calendarView.scrollToDate(date, animated: false)
        
        // Animate the month view visible
        UIView.animate(withDuration: 0.10, animations: { () -> Void in
            self.monthViewController.view.alpha = 1.0
        })
    }
    
    // ---------------------------------------------
    // MARK: - UI Methods
    // ---------------------------------------------
    
    fileprivate func initNavigationButtons() {
        var navigationButtons = [UIBarButtonItem]()
        // Navigation Buttons
        let refreshImage = UIImage.icon(.refresh).withRenderingMode(.alwaysTemplate)
        let refreshButton = UIBarButtonItem(image: refreshImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CalendarSplitMonthViewController.refreshButtonPressed(_:)))
        refreshButton.accessibilityLabel = NSLocalizedString("Refresh Button", comment: "")
        refreshButton.accessibilityHint = NSLocalizedString("Refreshes the calendar content", comment: "")
        navigationButtons.append(refreshButton)
        
        if let todayView = IconTodayView.instantiateFromNib(Date(), tintColor: self.navigationController?.navigationBar.tintColor, target: self, action: #selector(CalendarSplitMonthViewController.todayButtonPressed(_:))) {
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
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        todayButtonAction(sender)
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        reloadData(true)
    }
    
    fileprivate func reloadView(_ date: Date) {
        lblMonthName.text = monthDateFormatter.string(from: date)
        lblDayOfWeek.text = dayOfWeekDateFormatter.string(from: date)
        lblDayOfMonth.text = dayOfMonthDateFormatter.string(from: date)
    }
    
    open func reloadData(_ forceUpdate: Bool = false) {
        monthViewController?.reloadData(forceUpdate)
        // day list view is reloaded in the completion callback for monthVC?.reloadData()
    }
    
    open func scrollToToday(_ animated: Bool) {
        monthViewController?.calendarView?.scrollToToday(animated)
    }
    
    fileprivate func setDay(_ date: Date) {
        dayListViewController?.day = date
        reloadView(date)
        reloadData()
    }
}

