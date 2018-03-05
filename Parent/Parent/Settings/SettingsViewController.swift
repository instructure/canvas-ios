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

typealias SettingsSessionAction = (_ session: Session)->Void
typealias SettingsObserveeSelectedAction = (_ session: Session, _ observee: Student)->Void

class SettingsViewController: UIViewController {
    
    // ---------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------
    var logoutButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    var addButton: UIBarButtonItem?
    var helpButton: UIBarButtonItem?
    @IBOutlet weak var observeesContainerView: UIView!

    var backgroundView: TriangleBackgroundGradientView!
    
    let reuseIdentifier = "SettingsObserveesCell"
    
    // ---------------------------------------------
    // MARK: - ViewModel
    // ---------------------------------------------
    var viewModel: SettingsViewModel!
    var observeesViewController: StudentsListViewController?
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------
    var closeAction: SettingsSessionAction? = nil
    var logoutAction: SettingsSessionAction? = nil
    var addObserveeAction: SettingsSessionAction? = nil
    var viewGuidesAction: SettingsSessionAction? = nil
    var reportProblemAction: SettingsSessionAction? = nil
    var requestFeatureAction: SettingsSessionAction? = nil
    var allObserveesAction: SettingsSessionAction? = nil
    var observeeSelectedAction: SettingsObserveeSelectedAction? = nil
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "SettingsViewController"
    static func new(_ storyboardName: String = defaultStoryboardName, session: Session) -> SettingsViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? SettingsViewController else {
            fatalError("Initial ViewController is not of type SettingsViewController")
        }

        controller.viewModel = SettingsViewModel(session: session)
        controller.observeesViewController = try! StudentsListViewController(session: session)
        controller.observeesViewController?.selectStudentAction = { [weak controller] session, student in
            controller?.observeeSelectedAction?(session, student)
        }
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - LifeCycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        setupObserveeList()

        self.title = NSLocalizedString("Settings", comment: "Title of the settings screen")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
        setupToolbar()
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        setupCloseButton()
        setupRightNavigationItem()
        if let navBar = self.navigationController?.navigationBar as? TriangleGradientNavigationBar {
            let scheme = ColorCoordinator.colorSchemeForParent()
            navBar.transitionToColors(scheme.tintTopColor, bottomTintColor: scheme.tintBottomColor)
        }
    }

    func setupRightNavigationItem() {
        setupAddButton()
        setupHelpButton()
        guard let helpButton = helpButton, let addButton = addButton else {
            return
        }
        self.navigationItem.rightBarButtonItems = [addButton, helpButton]
    }

    func setupHelpButton() {
        let helpButton = UIBarButtonItem(image: UIImage.RTLImage("icon_help"), style: .plain, target: self, action: #selector(SettingsViewController.helpButtonPressed(_:)))
        helpButton.accessibilityLabel = NSLocalizedString("Help", comment: "Help Button Title")
        helpButton.accessibilityIdentifier = "help_button"
        helpButton.tintColor = UIColor.white

        self.helpButton = helpButton
    }

    func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SettingsViewController.addButtonPressed(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add Student", comment: "Add Student Settings Button Title")
        addButton.accessibilityIdentifier = "add_observee_button"
        addButton.tintColor = UIColor.white

        self.addButton = addButton
    }

    func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(SettingsViewController.closeButtonPressed(_:)))
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
        closeButton.accessibilityIdentifier = "close_button"
        closeButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = closeButton

        self.closeButton = closeButton
    }

    func setupObserveeList() {
        guard let observeesViewController = observeesViewController else {
            return
        }

        observeesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        observeesViewController.willMove(toParentViewController: self)
        addChildViewController(observeesViewController)
        observeesContainerView.addSubview(observeesViewController.view)
        observeesViewController.didMove(toParentViewController: self)
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
        observeesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
    }

    func setupToolbar() {
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.backgroundColor = UIColor.white
        
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let logoutTitle = NSLocalizedString("Logout", comment: "Logout Confirm Button")
        let logoutButton = UIBarButtonItem(title: logoutTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.logoutButtonPressed(_:)))
        logoutButton.accessibilityIdentifier = "logout_button"
        self.toolbarItems = [rightSpace, logoutButton, leftSpace]

        self.logoutButton = logoutButton
    }

    // ---------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to logout?", comment: "Logout Confirmation"), preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout Confirm Button"), style: .destructive) { [weak self] _ in
            guard let me = self else { return }
            me.dismiss(animated: true) {
                me.logoutAction?(me.viewModel.session)
            }
        }
        alertController.addAction(destroyAction)

        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.barButtonItem = sender
        self.present(alertController, animated: true) { }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        closeAction?(viewModel.session)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addObserveeAction?(viewModel.session)
    }

    @IBAction func helpButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("How can we help?", comment: "Help Menu Message"), preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        let guideAction = UIAlertAction(title: NSLocalizedString("Help Guide", comment: "Help Guide Button"), style: .default) { [weak self] _ in
            guard let me = self else { return }
            me.viewGuidesAction?(me.viewModel.session)
        }
        alertController.addAction(guideAction)

        let shareLoveAction = UIAlertAction(title: NSLocalizedString("Share Some Love", comment: "Share Some Love Button"), style: .default) { _ in
            let appURL = URL(string: "itms://itunes.apple.com/us/app/apple-store/id1097996698?mt=8")!
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        }
        alertController.addAction(shareLoveAction)

        let problemAction = UIAlertAction(title: NSLocalizedString("Report a Problem", comment: "Report Problem Button"), style: .default) { [weak self] _ in
            guard let me = self else { return }
            me.reportProblemAction?(me.viewModel.session)
        }
        alertController.addAction(problemAction)

        let featureAction = UIAlertAction(title: NSLocalizedString("Request a Feature", comment: "Feature Request Button"), style: .default) { [weak self] _ in
            guard let me = self else { return }
            me.requestFeatureAction?(me.viewModel.session)
        }
        alertController.addAction(featureAction)

        let openSource = UIAlertAction(title: NSLocalizedString("Open Source Components", comment: "Open Source Components Button"), style: .default) { [weak self] _ in
            guard let me = self else { return }
            let thankful = OSSAttributionViewController()
            thankful.hidesBottomBarWhenPushed = true
            me.navigationController?.pushViewController(thankful, animated: true)
        }
        alertController.addAction(openSource)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.barButtonItem = sender
        self.present(alertController, animated: true) { }
    }
    
    func addObservee() {
        addObserveeAction?(viewModel.session)
    }
}
