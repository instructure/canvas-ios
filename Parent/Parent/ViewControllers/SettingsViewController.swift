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
import PeepKit

typealias SettingsCloseAction = (session: Session)->Void
typealias SettingsLogoutAction = (session: Session)->Void
typealias SettingsAddObserveeAction = (session: Session)->Void
typealias SettingsAllObserveeAction = (session: Session)->Void
typealias SettingsObserveeSelectedAction = (session: Session, observee: User)->Void

class SettingsViewController: UIViewController {
    
    // ---------------------------------------------
    // MARK: - IBOutlets
    // ---------------------------------------------
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    let reuseIdentifier = "SettingsObserveesCell"
    
    // ---------------------------------------------
    // MARK: - ViewModel
    // ---------------------------------------------
    var viewModel: SettingsViewModel!
    var observeesViewController: UIViewController?
    
    // ---------------------------------------------
    // MARK: - External Closures
    // ---------------------------------------------
    var closeAction: SettingsLogoutAction? = nil
    var logoutAction: SettingsLogoutAction? = nil
    var addObserveeAction: SettingsAddObserveeAction? = nil
    var allObserveesAction: SettingsAllObserveeAction? = nil
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
//        controller.observeesViewController = try! userObserveeListViewController(session, viewModelFactory: { VanillaViewModel(name: "", avatarURL: "") })
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - LifeCycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "closeButtonPressed:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        self.navigationController?.toolbarHidden = false
        
        nameLabel.text = viewModel.nameText()
        emailLabel.text = viewModel.emailText()
        avatarImageView.image = UIImage(named: "icon_user")
        if let url = viewModel.session.user.avatarURL {
            avatarImageView.download(url: url, contentMode: .ScaleAspectFit)
        }
        
        guard let observeesViewController = observeesViewController else {
            return
        }
        
        addChildViewController(observeesViewController)
        self.view.addSubview(observeesViewController.view)
        observeesViewController.didMoveToParentViewController(self)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observeesViewController.view]))
        
    }

    // ---------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------
    @IBAction func logoutButtonPressed(sender: UIButton) {
        logoutAction?(session: viewModel.session)
    }
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        closeAction?(session: viewModel.session)
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        addObserveeAction?(session: viewModel.session)
    }
    
    func addObservee() {
        addObserveeAction?(session: viewModel.session)
    }
}

struct VanillaViewModel: TableViewCellViewModel {
    
    static let reuseIdentifier = "UserCell"
    
    let name: String
    let avatarURL: String?
    
    static func tableViewDidLoad(tableView: UITableView) {
//        tableView.registerNib(UINib(nibName: "UserCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: VanillaViewModel.reuseIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = 100
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(VanillaViewModel.reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = name
        
        return cell
    }
}

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

