//
//  AccountDomainsTableViewController.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/4/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

import TooLegit
import SoLazy

public typealias PickDomainSuccessfulAction = (AccountDomain) -> ()

class AccountDomainsTableViewController: UITableViewController {
    // ---------------------------------------------
    // MARK: - static values
    // ---------------------------------------------
    let reuseIdentifier = "AccountDomainCellReuseIdentifier"
    // Fake Session to make requests
    private static let session : Session = {
        let user = User(id: "AccountDomains", loginID: "AccountDomainsID", name: "AccountDomains", sortableName: "AccountDomains", email: "AccountDomains@instructure.com", avatarURL: NSURL())
        return Session(token: nil, baseURL: NSURL(string: "https://canvas.instructure.com")!, currentUser: user)
    }()
    
    // ---------------------------------------------
    // MARK: - Instance Variables
    // ---------------------------------------------
    var pickedDomainAction : PickDomainSuccessfulAction = { domain in
        print("Domain Picked:\t\(domain.name)")
    }
    private var crud: AccountDomainCRUD!
    private var frc: AccountDomainFRC!
    
    // When search term changes the results will filter automatically
    var searchTerm : String? {
        didSet {
            let frcRequest = AccountDomain.FRCRequestAccountDomainsForSearchTerm(searchTerm)
            frc = AccountDomain.FRC(AccountDomainsTableViewController.session, request: frcRequest)
            frc.frcChangeable = tableView
            tableView.reloadData()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "AccountDomainsTableViewController"
    static func new(storyboardName: String = defaultStoryboardName, pickedDomainAction: PickDomainSuccessfulAction) -> AccountDomainsTableViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass:object_getClass(self))).instantiateInitialViewController() as? AccountDomainsTableViewController else {
            fatalError("Initial ViewController is not of type AccountDomainsTableViewController")
        }
        
        controller.pickedDomainAction = pickedDomainAction
        controller.crud = AccountDomain.accountDomainCRUD(AccountDomainsTableViewController.session)
        let frcRequest = AccountDomain.FRCRequestAccountDomainsForSearchTerm(controller.searchTerm)
        controller.frc = AccountDomain.FRC(session, request: frcRequest)
        controller.frc.frcChangeable = controller.tableView
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
     
        frc.refreshFromServer(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ---------------------------------------------
    // MARK: - UITableViewDataSource
    // ---------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        configureCell(indexPath, cell: cell)
        return cell
    }
    
    func configureCell(indexPath: NSIndexPath, cell: UITableViewCell) {
        guard let cell = cell as? AccountDomainTableViewCell else {
            fatalError("Expected a MultiUserTableViewCell")
        }
        
        let domain = frc.objectAt(indexPath)
        cell.domain = domain
    }
    
    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let domain = frc.objectAt(indexPath)
        pickedDomainAction(domain)
    }
    

}
