//
// Copyright (C) 2018-present Instructure, Inc.
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
import ReactiveSwift
import Marshal
import CanvasCore

private struct AccountNotification: Codable {
    let subject: String
    let message: String
}

class AccountNotificationViewController: UITableViewController {
    var details: [AnnouncementDetailsCellViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var disposable: Disposable?

    init(session: Session, announcementID: String) throws {
        super.init(style: .plain)
        let request = try session.GET("/api/v1/accounts/self/account_notifications/\(announcementID)")
        let producer = session.JSONSignalProducer(request)
            .flatMap(.merge) { (json: JSONObject) -> SignalProducer<AccountNotification, NSError> in
                attemptProducer { () -> AccountNotification in
                    let decoder = JSONDecoder()
                    let data = try json.jsonData()
                    return try decoder.decode(AccountNotification.self, from: data)
                }
        }
        producer.startWithSignal { signal, disposable in
            signal.observe { event in
                disposable.dispose()
                switch event {
                case .value(let notification):
                    self.details = [
                        .title(notification.subject),
                        .message(session.baseURL, notification.message)
                    ]
                case .failed(let error):
                    if error.code == 401 {
                        let message = NSLocalizedString("This announcement has expired.", comment: "")
                        let markup = """
                        <div style='display:flex;align-items:center;justify-content:center;'>
                            <p>\(message)</p>
                        </div>
                        """
                        self.details = [
                            .message(session.baseURL, markup)
                        ]
                    } else {
                        ErrorReporter.reportError(error, from: self)
                    }
                case .completed, .interrupted:
                    break
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Announcement", comment: "")
        tableView.dataSource = self
        AnnouncementDetailsCellViewModel.tableViewDidLoad(tableView)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = details[indexPath.row]
        let cell = row.cellForTableView(tableView, indexPath: indexPath)
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
}
