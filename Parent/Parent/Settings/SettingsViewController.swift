//
//  SettingsViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import SoPersistent
import TooLegit
import Airwolf
import SoPretty

typealias SettingsSessionAction = (session: Session)->Void
typealias SettingsObserveeSelectedAction = (session: Session, observee: Student)->Void

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
    private static let defaultStoryboardName = "SettingsViewController"
    static func new(storyboardName: String = defaultStoryboardName, session: Session) -> SettingsViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? SettingsViewController else {
            fatalError("Initial ViewController is not of type SettingsViewController")
        }

        controller.viewModel = SettingsViewModel(session: session)
        controller.observeesViewController = try! StudentsListViewController(session: session)
        controller.observeesViewController?.selectStudentAction = { session, student in
            controller.observeeSelectedAction?(session: session, observee: student)
        }
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - LifeCycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        setupObserveeList()

        self.title = "Settings"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar()
        setupToolbar()
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    func setupNavigationBar() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

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
        guard let helpButton = helpButton, addButton = addButton else {
            return
        }
        self.navigationItem.rightBarButtonItems = [addButton, helpButton]
    }

    func setupHelpButton() {
        let helpButton = UIBarButtonItem(image: UIImage(named: "icon_help"), style: .Plain, target: self, action: #selector(SettingsViewController.helpButtonPressed(_:)))
        helpButton.accessibilityLabel = NSLocalizedString("Help", comment: "Help Button Title")
        helpButton.accessibilityIdentifier = "help_button"
        helpButton.tintColor = UIColor.whiteColor()

        self.helpButton = helpButton
    }

    func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(SettingsViewController.addButtonPressed(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add Student", comment: "Add Student Settings Button Title")
        addButton.accessibilityIdentifier = "add_observee_button"
        addButton.tintColor = UIColor.whiteColor()

        self.addButton = addButton
    }

    func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(SettingsViewController.closeButtonPressed(_:)))
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
        closeButton.accessibilityIdentifier = "close_button"
        closeButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = closeButton

        self.closeButton = closeButton
    }

    func setupObserveeList() {
        guard let observeesViewController = observeesViewController else {
            return
        }

        observeesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        observeesViewController.willMoveToParentViewController(self)
        addChildViewController(observeesViewController)
        observeesContainerView.addSubview(observeesViewController.view)
        observeesViewController.didMoveToParentViewController(self)
        observeesContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
        observeesContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
    }

    func setupToolbar() {
        self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.backgroundColor = UIColor.whiteColor()
        
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingsViewController.logoutButtonPressed(_:)))
        logoutButton.accessibilityIdentifier = "logout_button"
        self.toolbarItems = [rightSpace, logoutButton, leftSpace]

        self.logoutButton = logoutButton
    }

    // ---------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to logout?", comment: "Logout Confirmation"), preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout Confirm Button"), style: .Destructive) { [weak self] _ in
            guard let me = self else { return }
            me.logoutAction?(session: me.viewModel.session)
        }
        alertController.addAction(destroyAction)

        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        closeAction?(session: viewModel.session)
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        addObserveeAction?(session: viewModel.session)
    }

    @IBAction func helpButtonPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("How can we help?", comment: "Help Menu Message"), preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .Cancel) { _ in }
        alertController.addAction(cancelAction)

        let guideAction = UIAlertAction(title: NSLocalizedString("Help Guide", comment: "Help Guide Button"), style: .Default) { [weak self] _ in
            guard let me = self else { return }
            me.viewGuidesAction?(session: me.viewModel.session)
        }
        alertController.addAction(guideAction)

        let shareLoveAction = UIAlertAction(title: NSLocalizedString("Share Some Love", comment: "Share Some Love Button"), style: .Default) { _ in
            let appURL = NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id1097996698?mt=8")!
            UIApplication.sharedApplication().openURL(appURL)
        }
        alertController.addAction(shareLoveAction)

        let problemAction = UIAlertAction(title: NSLocalizedString("Report a Problem", comment: "Report Problem Button"), style: .Default) { [weak self] _ in
            guard let me = self else { return }
            me.reportProblemAction?(session: me.viewModel.session)
        }
        alertController.addAction(problemAction)

        let featureAction = UIAlertAction(title: NSLocalizedString("Request a Feature", comment: "Feature Request Button"), style: .Default) { [weak self] _ in
            guard let me = self else { return }
            me.requestFeatureAction?(session: me.viewModel.session)
        }
        alertController.addAction(featureAction)

        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(alertController, animated: true) { }
    }
    
    func addObservee() {
        addObserveeAction?(session: viewModel.session)
    }
}
