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
    
    

import UIKit
import WhizzyWig
import Cartography
import SoLazy

class QuizDetailsViewController: UITableViewController {
    
    // displayed properties - this is just a dummy view controller
    
    var quiz: Quiz? {
        didSet {
            quizUpdated()
        }
    }
    
    // other properties
    
    private let baseURL: NSURL
    private var details: [(String, String)] = []

    let descriptionCell = WhizzyWigTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "WhoCares")

    // initialization

    init(quiz: Quiz?, baseURL: NSURL) {
        self.quiz = quiz
        self.baseURL = baseURL
        super.init(nibName: nil, bundle: nil)
     }

    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }
    
    // preparations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTable()
        prepareDescriptionCell()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    private func prepareTable() {
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20+44+20)) // padding for scrolling above the page indicator, TODO: make constants
        tableView.registerNib(QuizDetailCell.Nib, forCellReuseIdentifier: QuizDetailCell.ReuseID)
    }
    
    private func prepareDescriptionCell() {
        descriptionCell.cellSizeUpdated = { [weak self] cell in
            if let me = self {
                let tv = me.tableView
                tv.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
            }
        }
        descriptionCell.selectionStyle = .None
    }
    
    private func prepareTheDetails() {
        var deets = [(String, String)]()
        
        let DueDateLabel = NSLocalizedString("Due Date", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "due date label for quiz due date")
        deets.append((DueDateLabel, self.quiz?.due.description ?? ""))
        
        let PointsLabel = NSLocalizedString("Points", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "label for number of points in a quiz")
        deets.append((PointsLabel, self.quiz?.scoring.description ?? ""))
        
        let QuestionCountLabel = NSLocalizedString("Questions", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "label for the number of questions")
        deets.append((QuestionCountLabel, String(self.quiz?.questionCount ?? 0)))
        
        // TODO: add availability
        let _ = NSLocalizedString("Available Until", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "label for quiz availability date")
        
        let TimeLimitLabel = NSLocalizedString("Time Limit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "label for the time limit")
        deets.append((TimeLimitLabel, self.quiz?.timeLimit.description ?? ""))
        
        let AttemptsLabel = NSLocalizedString("Allowed Attempts", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "label for number of attempts that are allowed")
        let allowed = self.quiz?.attemptLimit.description ?? ""
        deets.append((AttemptsLabel, allowed))
        
        details = deets
    }
    
    private func prepareTheDescription() {
        descriptionCell.whizzyWigView.loadHTMLString(self.quiz?.description ?? "", baseURL: baseURL)
    }
    
    private func quizUpdated() {
        prepareTheDetails()
        prepareTheDescription()
        
        if isViewLoaded() {
            tableView.reloadData()
        }
    }
}

extension QuizDetailsViewController {

    // table view
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return quiz == nil ? 0 : 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // an extra 1 for the padding at the top, didn't use section headers because of the sticky headers
        switch section {
        case 0: // title
            return 1 + 1
        case 1: // description
            if let quiz = quiz {
                if quiz.lockedForUser {
                    return 0
                }
            }
            if quiz?.description == "" {
                return 0
            }
            return 1 + 1
        case 2:
            return details.count + 1
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getPaddingCell()
        }
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("QuizTitleCell") 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "QuizTitleCell")
                cell?.textLabel?.textAlignment = .Center
                cell?.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
            }
            cell!.textLabel?.text = quiz?.title ?? ""
            return cell!
        } else if indexPath.section == 1 {
            return descriptionCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(QuizDetailCell.ReuseID) as! QuizDetailCell
            let deets = details[indexPath.row-1] // 1 for the padding cell
            cell.itemLabel.text = deets.0
            cell.detailLabel.text = deets.1
            return cell;
        }
    }
    
    private func getPaddingCell() -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PaddingCell") 
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "PaddingCell")
            constrain(cell!.contentView) { contentView in
                contentView.height == 30; return
            }
        }
        return cell!
    }
}

