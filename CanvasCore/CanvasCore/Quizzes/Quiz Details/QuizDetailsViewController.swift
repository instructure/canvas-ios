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

import Cartography


class QuizDetailsViewController: UITableViewController {
    
    // displayed properties - this is just a dummy view controller
    
    var quiz: Quiz? {
        didSet {
            quizUpdated()
        }
    }
    
    // other properties
    
    fileprivate let baseURL: URL
    fileprivate var details: [(String, String)] = []

    let descriptionCell = WhizzyWigTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "WhoCares")

    // initialization

    init(quiz: Quiz?, baseURL: URL) {
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
    
    fileprivate func prepareTable() {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20+44+20)) // padding for scrolling above the page indicator, TODO: make constants
        tableView.register(QuizDetailCell.Nib, forCellReuseIdentifier: QuizDetailCell.ReuseID)
    }
    
    fileprivate func prepareDescriptionCell() {
        descriptionCell.cellSizeUpdated = { [weak self] cell in
            if let me = self {
                let tv = me.tableView
                tv?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        }
        descriptionCell.readMore = { wwvc in
            let nav = UINavigationController(rootViewController: wwvc)
            self.present(nav, animated: true) {
                wwvc.whizzyWigView.loadHTMLString(self.quiz?.description ?? "", baseURL: self.baseURL)
            }
        }
        descriptionCell.selectionStyle = .none
    }
    
    fileprivate func prepareTheDetails() {
        var deets = [(String, String)]()
        
        let DueDateLabel = NSLocalizedString("Due Date", tableName: "Localizable", bundle: .core, value: "", comment: "due date label for quiz due date")
        deets.append((DueDateLabel, self.quiz?.due.description ?? ""))
        
        let PointsLabel = NSLocalizedString("Points", tableName: "Localizable", bundle: .core, value: "", comment: "label for number of points in a quiz")
        deets.append((PointsLabel, self.quiz?.scoring.description ?? ""))
        
        let QuestionCountLabel = NSLocalizedString("Questions", tableName: "Localizable", bundle: .core, value: "", comment: "label for the number of questions")
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        let questionCountString = formatter.string(from: NSNumber(value: self.quiz?.questionCount ?? 0)) ?? ""
        deets.append((QuestionCountLabel, questionCountString))
        
        // TODO: add availability
        let _ = NSLocalizedString("Available Until", tableName: "Localizable", bundle: .core, value: "", comment: "label for quiz availability date")
        
        let TimeLimitLabel = NSLocalizedString("Time Limit", tableName: "Localizable", bundle: .core, value: "", comment: "label for the time limit")
        deets.append((TimeLimitLabel, self.quiz?.timeLimit.description ?? ""))
        
        let AttemptsLabel = NSLocalizedString("Allowed Attempts", tableName: "Localizable", bundle: .core, value: "", comment: "label for number of attempts that are allowed")
        let allowed = self.quiz?.attemptLimit.description ?? ""
        deets.append((AttemptsLabel, allowed))
        
        details = deets
    }
    
    fileprivate func prepareTheDescription() {
        descriptionCell.whizzyWigView.loadHTMLString(self.quiz?.description ?? "", baseURL: baseURL)
    }
    
    fileprivate func quizUpdated() {
        prepareTheDetails()
        prepareTheDescription()
        
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}

extension QuizDetailsViewController {

    // table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return quiz == nil ? 0 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getPaddingCell()
        }
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "QuizTitleCell") 
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "QuizTitleCell")
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                cell?.textLabel?.numberOfLines = 0
            }
            cell!.textLabel?.text = quiz?.title ?? ""
            return cell!
        } else if indexPath.section == 1 {
            return descriptionCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: QuizDetailCell.ReuseID) as! QuizDetailCell
            let deets = details[indexPath.row-1] // 1 for the padding cell
            cell.itemLabel.text = deets.0
            cell.detailLabel.text = deets.1
            cell.itemLabel.numberOfLines = 0
            cell.detailLabel.numberOfLines = 0
            cell.itemLabel.font = UIFont.preferredFont(forTextStyle: .body)
            cell.detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
            return cell;
        }
    }
    
    fileprivate func getPaddingCell() -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PaddingCell") 
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "PaddingCell")
            constrain(cell!.contentView) { contentView in
                contentView.height == 30; return
            }
        }
        return cell!
    }
}

