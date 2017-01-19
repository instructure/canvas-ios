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

open class SelectSessionListViewController: UITableViewController {

    public typealias PickSessionAction = (Session) -> ()
    var sessions = [Session]()
    let reuseIdentifier = "MultiUserCellReuseIdentifier"
    open var pickedSessionAction : PickSessionAction = { session in
        print("Session Picked:\n  \t\(session)")
    }
    open var sessionDeleted : PickSessionAction? = { session in
        print("Session Deleted:\n  \t\(session)")
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "SelectSessionListViewController"
    open static func new(_ storyboardName: String = defaultStoryboardName) -> SelectSessionListViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for:object_getClass(self))).instantiateInitialViewController() as? SelectSessionListViewController else {
            ❨╯°□°❩╯⌢"Initial ViewController is not of type MultiUserTableViewController"
        }

        return controller
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50.0
        reloadData()
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ---------------------------------------------
    // MARK: - UITableViewDataSource
    // ---------------------------------------------
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        configureCell(indexPath, cell: cell)
        return cell
    }

    func configureCell(_ indexPath: IndexPath, cell: UITableViewCell) {
        guard let cell = cell as? SelectSessionTableViewCell else {
            ❨╯°□°❩╯⌢"Expected a SelectSessionTableViewCell"
        }

        let session = sessions[indexPath.row]
        cell.session = session

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(SelectSessionListViewController.deleteButtonPressed(_:)), for: .touchUpInside)
        cell.deleteButton.isHidden = sessionDeleted == nil
        cell.accessoryType = sessionDeleted == nil ? .disclosureIndicator : .none

        if indexPath.row == sessions.count - 1 {
            cell.roundCorners([.bottomRight, .bottomLeft], radius: 10.0)
        } else {
            cell.layer.mask = nil
        }
    }

    // ---------------------------------------------
    // MARK: - UITableViewDelegate
    // ---------------------------------------------
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let session = sessions[indexPath.row]
        pickedSessionAction(session)
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        guard sessions.count > tag else {
            ❨╯°□°❩╯⌢"Multi User Tag is somehow higher than number of sessions"
        }

        let session = sessions[tag]
        Keymaster.sharedInstance.deleteSession(session)
        removeSessionAtIndex(tag)
        sessionDeleted?(session)
    }

    func removeSessionAtIndex(_ index: Int) {
        self.sessions.remove(at: index)

        // reload everything below and 1 above, just in case we reuse the cell and the corners are rounded
        let reloadCells = tableView.indexPathsForVisibleRows?.filter{ $0.row > index || $0.row == index - 1}

        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
        if let reloadCells = reloadCells {
            tableView.reloadRows(at: reloadCells, with: .automatic)
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
