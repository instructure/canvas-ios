//
//  MultiUserTableViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 12/2/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit

public typealias PickUserSuccessfulAction = (Session) -> ()

class MultiUserTableViewController: UITableViewController {
    
    var sessions = [Session]()
    let reuseIdentifier = "MultiUserCellReuseIdentifier"
    var pickedSessionAction : PickUserSuccessfulAction = { session in
        print("User Picked:\n  AuthToken:\t\(session.auth.token)")
    }
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "MultiUserTableViewController"
    static func new(storyboardName: String = defaultStoryboardName, pickedSessionAction: PickUserSuccessfulAction) -> MultiUserTableViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass:object_getClass(self))).instantiateInitialViewController() as? MultiUserTableViewController else {
            fatalError("Initial ViewController is not of type MultiUserTableViewController")
        }
        
        controller.pickedSessionAction = pickedSessionAction
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ---------------------------------------------
    // MARK: - UITableViewDataSource
    // ---------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        configureCell(indexPath, cell: cell)
        return cell
    }
    
    func configureCell(indexPath: NSIndexPath, cell: UITableViewCell) {
        guard let cell = cell as? MultiUserTableViewCell else {
            fatalError("Expected a MultiUserTableViewCell")
        }
        
        let session = sessions[indexPath.row]
        cell.session = session
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
    }
    
    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let session = sessions[indexPath.row]
        pickedSessionAction(session)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func deleteButtonPressed(sender: UIButton) {
        let tag = sender.tag
        guard sessions.count > tag else {
            fatalError("Multi User Tag is somehow higher than number of sessions")
        }
        
        let session = sessions[tag]
        Keymaster.instance.deleteSession(session)
        removeSessionAtIndex(tag)
    }
    
    func removeSessionAtIndex(index: Int) {
        self.sessions.removeAtIndex(index)
        
        let reloadCells = tableView.indexPathsForVisibleRows?.filter{ $0.row > index }
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        if let reloadCells = reloadCells {
            tableView.reloadRowsAtIndexPaths(reloadCells, withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func reloadData() {
        let user1 = User(id: "12", loginID: "12", name: "Name", sortableName: "Sortable Name", email: "email", avatarURL: NSURL(string: "http://URL.HERE"))
        let session1 = Session(token: "Token", baseURL: NSURL(string: "mobiledev.instructure.com")!, currentUser: user1)
        let user2 = User(id: "13", loginID: "14", name: "Name 2", sortableName: "Sortable Name", email: "email", avatarURL: NSURL(string: "http://URL.HERE"))
        let session2 = Session(token: "Token", baseURL: NSURL(string: "mobiledev.instructure.com")!, currentUser: user2)
        
        self.sessions = [session1, session2]
        
        //        self.sessions = Keymaster.instance.savedSessions()
        
        tableView.reloadData()
    }

}
