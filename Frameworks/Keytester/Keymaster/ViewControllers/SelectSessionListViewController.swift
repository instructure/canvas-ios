
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import SoLazy
import TooLegit

public class SelectSessionListViewController: UITableViewController {

    public typealias PickSessionAction = (Session) -> ()
    var sessions = [Session]()
    let reuseIdentifier = "MultiUserCellReuseIdentifier"
    public var pickedSessionAction : PickSessionAction = { session in
        print("Session Picked:\n  \t\(session)")
    }
    public var sessionDeleted : PickSessionAction? = { session in
        print("Session Deleted:\n  \t\(session)")
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "SelectSessionListViewController"
    public static func new(storyboardName: String = defaultStoryboardName) -> SelectSessionListViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass:object_getClass(self))).instantiateInitialViewController() as? SelectSessionListViewController else {
            ❨╯°□°❩╯⌢"Initial ViewController is not of type MultiUserTableViewController"
        }

        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50.0
        reloadData()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ---------------------------------------------
    // MARK: - UITableViewDataSource
    // ---------------------------------------------
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        configureCell(indexPath, cell: cell)
        return cell
    }

    func configureCell(indexPath: NSIndexPath, cell: UITableViewCell) {
        guard let cell = cell as? SelectSessionTableViewCell else {
            ❨╯°□°❩╯⌢"Expected a SelectSessionTableViewCell"
        }

        let session = sessions[indexPath.row]
        cell.session = session

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(SelectSessionListViewController.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        cell.deleteButton.hidden = sessionDeleted == nil
        cell.accessoryType = sessionDeleted == nil ? .DisclosureIndicator : .None

        if indexPath.row == sessions.count - 1 {
            cell.roundCorners([.BottomRight, .BottomLeft], radius: 10.0)
        } else {
            cell.layer.mask = nil
        }
    }

    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
            ❨╯°□°❩╯⌢"Multi User Tag is somehow higher than number of sessions"
        }

        let session = sessions[tag]
        Keymaster.sharedInstance.deleteSession(session)
        removeSessionAtIndex(tag)
        sessionDeleted?(session)
    }

    func removeSessionAtIndex(index: Int) {
        self.sessions.removeAtIndex(index)

        // reload everything below and 1 above, just in case we reuse the cell and the corners are rounded
        let reloadCells = tableView.indexPathsForVisibleRows?.filter{ $0.row > index || $0.row == index - 1}

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Left)
        if let reloadCells = reloadCells {
            tableView.reloadRowsAtIndexPaths(reloadCells, withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
    }

    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func reloadData() {
        self.sessions = Keymaster.sharedInstance.savedSessions()
        tableView.reloadData()
    }

}
