//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

    var submission: QuizSubmission? {
        didSet {
            quizUpdated()
        }
    }
    
    // other properties
    
    fileprivate let baseURL: URL
    fileprivate var details: [(String, String)] = []

    let descriptionCell = WhizzyWigTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "WhoCares")

    // initialization

    init(quiz: Quiz?, baseURL: URL) {
        self.quiz = quiz
        self.baseURL = baseURL
        super.init(nibName: nil, bundle: nil)
     }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // preparations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTable()
        prepareDescriptionCell()
    }
    
    fileprivate func prepareTable() {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
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
        switch self.quiz?.timeLimit {
        case .some(.minutes(let limit)):
            let extraTime = self.submission?.extraTime ?? 0
            let newLimit = Quiz.TimeLimit(minutes: extraTime + limit)
            deets.append((TimeLimitLabel, newLimit.description))
        default:
            deets.append((TimeLimitLabel, ""))
        }

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
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "QuizTitleCell")
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
        cell?.selectionStyle = .none
        return cell!
    }
}

