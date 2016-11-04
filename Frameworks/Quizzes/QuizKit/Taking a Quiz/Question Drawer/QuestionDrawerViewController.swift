
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
import SoLazy

class QuestionDrawerViewController: UITableViewController {
    
    var questions: [SubmissionQuestion] = [] {
        didSet {
            flaggedQuestions = questions.filter({ question in
                return question.flagged
            })
        }
    }
    
    var questionSelectionAction: (questionIndex: Int)->() = { _ in }
    
    private var flaggedQuestions: [SubmissionQuestion] = []
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingQuestionView()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        tableView.registerNib(QuestionDrawerCell.Nib, forCellReuseIdentifier: QuestionDrawerCell.ReuseID)
        updateLoadingQuestionView()
    }
}

extension QuestionDrawerViewController {
    
    // MARK: UITableViewDatasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // flagged
            return flaggedQuestions.count
        } else if section == 1 { // all questions
            return questions.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionDrawerCell", forIndexPath: indexPath) as! QuestionDrawerCell
        
        if indexPath.section == 0 { // flagged
            let question = flaggedQuestions[indexPath.row]
            cell.displayState(.Flagged)
            cell.questionTextLabel.text = "Question \(question.question.position)"
        } else {
            let question = questions[indexPath.row]
            if question.flagged {
                cell.displayState(.Flagged)
            } else {
                switch question.answer {
                case .ID(_):
                    cell.displayState(.Answered)
                case .IDs(_):
                    cell.displayState(.Answered)
                case .Text(_):
                    cell.displayState(.Answered)
                case .Matches(let matches):
                    if matches.keys.count == question.question.answers.count {
                        cell.displayState(.Answered)
                    } else {
                        cell.displayState(.Untouched)
                    }
                default:
                    cell.displayState(.Untouched)
                    break
                }
            }
            
            cell.questionTextLabel.text = "Question \(question.question.position)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && flaggedQuestions.count > 0 { // flagged
            return "\(flaggedQuestions.count) Flagged"
        } else if section == 1 { // all questions
            return "All \(questions.count) Questions"
        }
        
        return nil
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 { // flagged
            let flaggedQuestion = flaggedQuestions[indexPath.row]
            let index = flaggedQuestion.question.position - 1 // position is 1 based, not 0 based
            questionSelectionAction(questionIndex: index)
        } else if indexPath.section == 1 { // all
            questionSelectionAction(questionIndex: indexPath.row)
        }
    }
}


// MARK: - Loading/Pagination

extension QuestionDrawerViewController {
    func updateLoadingQuestionView() {
        if !isViewLoaded() {
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
    func handleQuestionsUpdateResult(result: SubmissionQuestionsUpdateResult) {
        if let _ = result.error { // don't report the error - the presenting view already did
            return
        }
            
        else if let _ = result.value {
            // This is a neive but simple solution - in the future this might not work, if both the drawer and the
            // submission view are onscreen at the same time

            tableView.reloadData()
        }
    }
}


