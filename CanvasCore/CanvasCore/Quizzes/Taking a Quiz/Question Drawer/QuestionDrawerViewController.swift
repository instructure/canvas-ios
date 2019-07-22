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


class QuestionDrawerViewController: UITableViewController {
    
    var questions: [SubmissionQuestion] = [] {
        didSet {
            flaggedQuestions = questions.filter({ question in
                return question.flagged
            })
        }
    }
    
    @objc var questionSelectionAction: (_ questionIndex: Int)->() = { _ in }
    
    fileprivate var flaggedQuestions: [SubmissionQuestion] = []
    fileprivate static let questionNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    @objc var isLoading: Bool = false {
        didSet {
            updateLoadingQuestionView()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.register(QuestionDrawerCell.Nib, forCellReuseIdentifier: QuestionDrawerCell.ReuseID)
        updateLoadingQuestionView()
    }
}

extension QuestionDrawerViewController {
    
    // MARK: UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // flagged
            return flaggedQuestions.count
        } else if section == 1 { // all questions
            return questions.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionDrawerCell", for: indexPath) as! QuestionDrawerCell
        let question = indexPath.section == 0 ? flaggedQuestions[indexPath.row] : questions[indexPath.row]
        if question.flagged || indexPath.section == 0 {
            cell.displayState(.flagged)
        } else {
            switch question.answer {
            case .id(_):
                cell.displayState(.answered)
            case .ids(_):
                cell.displayState(.answered)
            case .text(_):
                cell.displayState(.answered)
            case .Matches(let matches):
                if matches.keys.count == question.question.answers.count {
                    cell.displayState(.answered)
                } else {
                    cell.displayState(.untouched)
                }
            default:
                cell.displayState(.untouched)
                break
            }
        }

        let template = NSLocalizedString("Question %@", tableName: "Localizable", bundle: .core, value: "", comment: "Shows question position")
        let position = String.localizedStringWithFormat(template, QuestionDrawerViewController.questionNumberFormatter.string(from: NSNumber(value: question.question.position)) ?? "")
        let spacer = NSLocalizedString("Spacer", tableName: "Localizable", bundle: .core, value: "", comment: "Text only quiz question label")
        cell.questionTextLabel.text = question.question.kind == .TextOnly ? spacer : position
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && flaggedQuestions.count > 0 { // flagged
            let template = NSLocalizedString("%@ Flagged", tableName: "Localizable", bundle: .core, value: "", comment: "Shows the number of flagged questions")
            return String.localizedStringWithFormat(template, QuestionDrawerViewController.questionNumberFormatter.string(from: NSNumber(value: flaggedQuestions.count)) ?? "")
        } else if section == 1 { // all questions
            let template = NSLocalizedString("All %@ Questions", tableName: "Localizable", bundle: .core, value: "", comment: "Shows the number questions")
            return String.localizedStringWithFormat(template, QuestionDrawerViewController.questionNumberFormatter.string(from: NSNumber(value: questions.count)) ?? "")
        }
        
        return nil
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 { // flagged
            let flaggedQuestion = flaggedQuestions[indexPath.row]
            let index = flaggedQuestion.question.position - 1 // position is 1 based, not 0 based
            questionSelectionAction(index)
        } else if indexPath.section == 1 { // all
            questionSelectionAction(indexPath.row)
        }
    }
}


// MARK: - Loading/Pagination

extension QuestionDrawerViewController {
    @objc func updateLoadingQuestionView() {
        if !isViewLoaded {
            return
        }
        
        if isLoading {
            let bounds = view.bounds
            let footer = LoadingQuestionsView.goGoGadgetLoadingQuestionsView()
            footer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 36)
            self.tableView.tableFooterView = footer
        } else {
            self.tableView?.tableFooterView = nil
        }
    }
}

// MARK: - Updates

extension QuestionDrawerViewController {
    func handleQuestionsUpdateResult(_ result: SubmissionQuestionsUpdateResult) {
        switch result {
        case .failure:
            // don't report the error - the presenting view already did
            return
        case .success:
            // This is a neive but simple solution - in the future this might not work, if both the drawer and the
            // submission view are onscreen at the same time
            tableView.reloadData()
        }
    }
}


