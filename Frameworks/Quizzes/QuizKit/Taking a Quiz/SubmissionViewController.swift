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
import Foundation
import WhizzyWig
import Cartography
import SoLazy

protocol SubmissionInteractor: class {
    var submission: Submission { get }
    func selectAnswer(_ answer: SubmissionAnswer, forQuestionAtIndex questionIndex: Int, completed: @escaping ()->())
    func markQuestonFlagged(_ flagged: Bool, forQuestionAtIndex questionIndex: Int)
}

class SubmissionViewController: UITableViewController {

    var quiz: Quiz?
    var questions: [SubmissionQuestion]
    let whizzyBaseURL: URL

    weak var submissionInteractor: SubmissionInteractor?
    var submitAction: ()->() = {}

    fileprivate var cellHeightCache: [Index: CGFloat] = [:]
    fileprivate var currentInputIndexPath: IndexPath? = nil

    var isLoading: Bool = true {
        didSet {
            updateLoadingStatus()
        }
    }

    init(quiz: Quiz?, questions: [SubmissionQuestion], whizzyBaseURL: URL) {
        self.quiz = quiz
        self.questions = questions
        self.whizzyBaseURL = whizzyBaseURL

        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    override func loadView() {
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        view = tableView
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag

        prepareTableView()
        updateLoadingStatus()
    }

    func navigateToQuestionAtIndex(_ questionIndex: Int) {
        let index = Index(questionIndex: questionIndex)
        tableView.scrollToRow(at: index.indexPath, at: .top, animated: true)
    }
}

// MARK: submit

extension SubmissionViewController {
    fileprivate func showSubmitButton() {
        let submit = NextOrSubmitView.createWithNextOrSubmit(.submit, target: self, action: #selector(SubmissionViewController.submit(_:)))
        let bounds = tableView.bounds
        submit.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 72)
        tableView?.tableFooterView = submit
    }

    func unSubmittedQuestionAndAnswer() -> (Int, SubmissionAnswer, UIResponder)? {
        for cell in tableView.visibleCells {
            guard let questionIndex = tableView.indexPath(for: cell).map(Index.init)?.questionIndex else { continue }

            if let answerCell = cell as? EssayAnswerCell, answerCell.textView.isFirstResponder {
                return (questionIndex, .text(answerCell.textView.text), answerCell.textView)
            } else if let answerCell = cell as? ShortAnswerCell, answerCell.textField.isFirstResponder {
                return (questionIndex, .text(answerCell.textField.text ?? ""), answerCell.textField)
            }
        }
        return nil
    }

    func submit(_ button: UIButton) {
        answerUnsubmittedQuestions() {
            self.submitAction()
        }
    }

    func answerUnsubmittedQuestions(_ done: @escaping ()->Void) {
        if let (questionIndex, answer, responder) = unSubmittedQuestionAndAnswer() {
            submissionInteractor?.selectAnswer(answer, forQuestionAtIndex: questionIndex) {
                responder.resignFirstResponder()
                done()
            }
        } else {
            done()
        }
    }
}

// MARK: - Updates

extension SubmissionViewController {
    func handleQuestionsUpdateResult(_ result: SubmissionQuestionsUpdateResult) {
        if let _ = result.error { // don't bother to report the error - the presenting vc already did
            return
        }

        else if let updates = result.value {
            self.tableView.beginUpdates()
            for update in updates {
                switch update {
                case .added(let questionIndex):
                    let sectionSet = NSIndexSet(index: questionIndex + 1)
                    self.tableView.insertSections(sectionSet as IndexSet, with: .fade)
                case .answerChanged(let questionIndex):
                    updateAnswersForQuestionAtIndex(questionIndex)
                case .flagChanged(let questionIndex):
                    updateFlagStatusForQuestionAtIndex(questionIndex)
                    break
                }
            }
            self.tableView.endUpdates()
        }
    }
}

// MARK: - loading (pagination)

extension SubmissionViewController {

    fileprivate func showLoadingView() {
        let footer = LoadingQuestionsView.goGoGadgetLoadingQuestionsView()
        let width = tableView.bounds.size.width
        footer.frame = CGRect(x: 0, y: 0, width: width, height: 34)
        tableView?.tableFooterView = footer
    }

    func updateLoadingStatus() {
        if !isViewLoaded {
            return
        }

        if isLoading {
            showLoadingView()
        } else {
            showSubmitButton()
        }
    }
}

// MARK: - UITableViewDataSource/Delegate

private let QuizDescriptionCellReuseID = "QuizDescriptionCellReuseID"

extension SubmissionViewController {

    enum Index: Hashable, CustomStringConvertible {
        case quizDescription
        case question(question: Int)
        case answer(question: Int, answer: Int)

        init(section: Int) {
            if section == 0 {
                self = .quizDescription
            } else {
                self = .question(question:section - 1)
            }
        }

        init(questionIndex: Int) {
            self = .question(question:questionIndex)
        }

        init(indexPath: IndexPath) {
            switch (indexPath.section, indexPath.row) {
            case (0, _):
                self = .quizDescription
            case (let section, 0):
                self = .question(question: section - 1)
            case (let section, let row):
                self = .answer(question: section - 1, answer: row - 1)
            }
        }

        var indexPath: IndexPath {
            switch self {
            case .quizDescription:
                return IndexPath(row: 0, section: 0)
            case let .question(question: questionIndex):
                return IndexPath(row: 0, section: questionIndex + 1)
            case let .answer(question: questionIndex, answer: answerIndex):
                return IndexPath(row: answerIndex + 1, section: questionIndex + 1)
            }
        }

        var hashValue: Int {
            switch self {
            case .quizDescription:
                return 1

            case .question(question: let q):
                return q << 1

            case .answer(question: let q, answer: let a):
                return (q << 1) + (a << 16)
            }
        }

        var questionIndex: Int? {
            switch self {
            case .question(question: let index):
                return index
            case .answer(question: let index, answer: _):
                return index
            default:
                return nil
            }
        }

        var description: String {
            switch self {
            case .question(question: let i):
                return "Question \(i)"

            case .quizDescription:
                return "Quiz Description"

            case let .answer(question: q, answer: a):
                return "Answer \(a) of Question \(q)"
            }
        }
    }

    fileprivate func prepareTableView() {
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.register(WhizzyWigTableViewCell.classForCoder(), forCellReuseIdentifier: QuizDescriptionCellReuseID)
        tableView.register(EssayAnswerCell.classForCoder(), forCellReuseIdentifier: EssayAnswerCell.ReuseID)
        tableView.register(TextAnswerCell.Nib, forCellReuseIdentifier: TextAnswerCell.ReuseID)
        tableView.register(HTMLAnswerCell.Nib, forCellReuseIdentifier: HTMLAnswerCell.ReuseID)
        tableView.register(ShortAnswerCell.Nib, forCellReuseIdentifier: ShortAnswerCell.ReuseID)
        tableView.register(MatchAnswerCell.Nib, forCellReuseIdentifier: MatchAnswerCell.ReuseID)
        tableView.register(QuestionHeaderView.Nib, forHeaderFooterViewReuseIdentifier: QuestionHeaderView.ReuseID)
    }

    // MARK: - UITableViewDatasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + questions.count
    }


    // returns 1(for the question itself) + number of answers
    fileprivate func numberOfRowsForQuestion(_ question: SubmissionQuestion) -> Int {
        if question.question.kind == .Essay || question.question.kind == .ShortAnswer || question.question.kind == .Numerical {
            // an essay question has no answers, but we need a row for the answer button
            return 2
        }
        return 1 + question.question.answers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Index(section: section) {
        case .quizDescription:
            if quiz != nil && quiz!.description == "" {
                return 0
            }
            return 1
        case .question(let questionIndex):
            let question = questions[questionIndex]
            return numberOfRowsForQuestion(question)
        default: break
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        // TODO: when abstracting out the height we need to decide if caching goes with the section
        // or is implemented once here (possibly twice for the 1.Q.A.A.T. quizzess). I'm thinking
        // cacheing shouldn't be done here, but instead each section should implement it, but perhaps
        // it can be done in a reusable way???
        if let height = cellHeightCache[Index(indexPath: indexPath)] {
            return height
        }

        // TODO: abstract this out. one fallback height isn't going to cut it. Also we should,
        // for accessiblity, make sure to use preferred text sizes and make sure that we are
        // sizing things appropriately. It would be so nice if we could just use autolayout.
        // maybe before we go to all the trouble of calculating it all ourselves we can give
        // automatic dimensions one more shot. /me shrugs

        switch Index(indexPath: indexPath) {
        case let .answer(qIndex, _):
            let question = questions[qIndex]
            switch question.question.kind {
            case .Essay:
                let height = EssayAnswerCell.heightWithText(question.answer.answerText ?? NSLocalizedString("Enter answer...", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Default text for essay cell"), boundsWidth: tableView.bounds.size.width)
                return height
            case .MultipleChoice, .MultipleAnswers, .TextOnly:
                let answerIndex = indexPath.row - 1
                let answer = question.question.answers[answerIndex]
                switch answer.content { // ignore HTML, should be handled by cell height cache
                case .text(let text):
                    return TextAnswerCell.heightWithText(text, boundsWidth: tableView.bounds.size.width)
                default: break
                }
            case .Matching:
                let answerIndex = indexPath.row - 1
                let answer = question.question.answers[answerIndex]
                var matchText = NSLocalizedString("Select Answer", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Indicates that a matching quiz question needs to have an answer selected")
                if let submissionAnswerMatchID = question.answer.matches?[answer.id], let match = question.question.matches?.filter({ $0.id == submissionAnswerMatchID})[0] {
                    matchText = match.text
                }
                switch answer.content { // ignore HTML, should be handled by cell height cache
                case .text(let text):
                    return MatchAnswerCell.heightWithAnswerText(text, matchText: matchText, boundsWidth: tableView.bounds.size.width)
                default: break
                }
            case .ShortAnswer, .Numerical:
                return 44.0
            default: break
            }

        default: break
        }

        return 60.0
    }

    fileprivate func updateHeight(_ height: CGFloat, forRowAtIndexPath indexPath: IndexPath) {

        // this prevents the text height bug. It's weird. but it works
        // other things might cause it to break.
        if tableView.rectForRow(at: indexPath).height == height {
            return
        }

        let index = Index(indexPath: indexPath)
        let existingHeight = cellHeightCache[index]
        if existingHeight != height {
            cellHeightCache[index] = height

            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }

    fileprivate func prepareWhizzyCell(_ cell: WhizzyWigTableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if let cachedHeight = cellHeightCache[Index(indexPath: indexPath)] {
            cell.expectedHeight = cachedHeight
        }
        cell.indexPath = indexPath
        cell.whizzyWigView.backgroundColor = UIColor.white
        cell.cellSizeUpdated = { [weak self] indexPath in
            self?.updateHeight(cell.expectedHeight, forRowAtIndexPath:indexPath); return
        }
    }

    // TODO: DON'T DUP THIS STUFF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    fileprivate func prepareHTMLAnswerCell(_ cell: HTMLAnswerCell, forRowAtIndexPath indexPath: IndexPath) {
        if let cachedHeight = cellHeightCache[Index(indexPath: indexPath)] {
            cell.expectedHeight = cachedHeight
        }
        cell.indexPath = indexPath
        cell.whizzyWigView.allowLinks = false
        cell.cellSizeUpdated = { [weak self] indexPath in
            self?.updateHeight(cell.expectedHeight, forRowAtIndexPath:indexPath as IndexPath); return
        }
        cell.configureForState(selected: false)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Index(section: section) {
        case .quizDescription:
            return nil
        case .question(let questionIndex):
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: QuestionHeaderView.ReuseID) as! QuestionHeaderView
            let question = questions[questionIndex]
            let position = question.question.position
            view.questionNumber = question.question.kind == .TextOnly ? nil : position
            view.questionFlagged = { [weak self] in
                if let me = self {
                    me.submissionInteractor?.markQuestonFlagged(view.flagged, forQuestionAtIndex: questionIndex)
                }
            }
            updateFlagStatusForHeaderView(view, question: question)
            return view
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Index(section: section) {
        case .quizDescription:
            return 0.0
        case .question( _):
            return 44.0
        default: return 0.0
        }
    }

    fileprivate func cellForQuizDescription(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuizDescriptionCellReuseID, for: indexPath) as! WhizzyWigTableViewCell
        return cell
    }

    fileprivate func cellForQuestion(_ question: SubmissionQuestion, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuizDescriptionCellReuseID, for: indexPath) as! WhizzyWigTableViewCell
        return cell
    }

    fileprivate func answerCellForQuestion(_ question: SubmissionQuestion, indexPath: IndexPath) -> UITableViewCell {
        switch question.question.kind {
        case .Essay:
            let questionIndex = Index(indexPath: indexPath).questionIndex!

            var essayText = question.answer.answerText ?? ""

            if let interactor = submissionInteractor {
                if essayText == "" {
                    essayText = EssayResponseCache.cachedEssayResponseForQuestion(question, ofSubmission: interactor.submission)
                }
            }

            if let _ = essayText.range(of: "<[^>]+>", options: .regularExpression) {
                // answer contains formatting or other HTML tags.

                let answerCell = tableView.dequeueReusableCell(withIdentifier: HTMLAnswerCell.ReuseID) as! HTMLAnswerCell
                answerCell.whizzyWigView.loadHTMLString(essayText, baseURL: whizzyBaseURL)
                prepareHTMLAnswerCell(answerCell, forRowAtIndexPath: indexPath)
                return answerCell
            } else {

                let essayCell = tableView.dequeueReusableCell(withIdentifier: EssayAnswerCell.ReuseID, for: indexPath) as! EssayAnswerCell

                essayCell.heightDidChange = { [weak self] height in
                    if let me = self {
                        me.updateHeight(height, forRowAtIndexPath:indexPath)
                    }
                }
                essayCell.doneEditing = { [weak self] text in
                    self?.submissionInteractor?.selectAnswer(.text(text), forQuestionAtIndex: questionIndex) {}
                    return
                }

                essayCell.inputText = essayText.stringByStrippingHTML()

                return essayCell
            }
        case .MultipleChoice, .MultipleAnswers, .TrueFalse:
            let answerIndex = indexPath.row - 1
            let answer = question.question.answers[answerIndex]
            switch answer.content {
            case .html( _):
                let answerCell = tableView.dequeueReusableCell(withIdentifier: HTMLAnswerCell.ReuseID) as! HTMLAnswerCell
                return answerCell;
            case .text( _):
                let textCell = tableView.dequeueReusableCell(withIdentifier: TextAnswerCell.ReuseID) as! TextAnswerCell
                return textCell
            }
        case .Matching:
            let answerIndex = indexPath.row - 1
            let answer = question.question.answers[answerIndex]
            switch answer.content {
            case .text( _):
                let matchCell = tableView.dequeueReusableCell(withIdentifier: MatchAnswerCell.ReuseID) as! MatchAnswerCell
                return matchCell
            default:
                return UITableViewCell()
            }
        case .ShortAnswer, .Numerical:
            let answerCell = tableView.dequeueReusableCell(withIdentifier: ShortAnswerCell.ReuseID) as! ShortAnswerCell
            return answerCell
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Index(indexPath: indexPath) {
        case .quizDescription:
            return cellForQuizDescription(indexPath)

        case .question(let questionIndex):
            let question = questions[questionIndex]
            return cellForQuestion(question, indexPath: indexPath)

        case .answer(question: let questionIndex, answer: _):
            let question = questions[questionIndex]
            return answerCellForQuestion(question, indexPath: indexPath)
        }
    }


    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Index(indexPath: indexPath) {
        case .answer(question: let questionIndex, answer: let answerIndex):
            let question = self.questions[questionIndex]

            switch question.question.kind {

            case .MultipleChoice, .TrueFalse:
                let answer = question.question.answers[answerIndex]
                self.submissionInteractor?.selectAnswer(.id(answer.id), forQuestionAtIndex: questionIndex) {}

            case .MultipleAnswers:
                let answer = question.question.answers[answerIndex]
                self.submissionInteractor?.selectAnswer(question.answer.toggleAnswerID(answer.id), forQuestionAtIndex: questionIndex) {}

            case .Matching:
                if let cell = tableView.cellForRow(at: indexPath) as? MatchAnswerCell {
                    cell.hiddenTextField.becomeFirstResponder()
                    _ = question.question.answers[answerIndex]
                    if let index = cell.pickerItems.index(of: cell.matchLabel.text ?? "") {
                        cell.pickerView.selectRow(index, inComponent: 0, animated: false)
                    }
                }
                break

            case .Essay:
                let cell = tableView.cellForRow(at: indexPath)
                if let cell = cell as? EssayAnswerCell {
                    cell.textView.becomeFirstResponder()
                } else if let _ = cell as? HTMLAnswerCell {
                    let title = NSLocalizedString("Warning", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "a warning message")
                    let message = NSLocalizedString("This essay question has been edited on the web and may contain formatting, links or images. In order to edit this response on your mobile device we will need to clear the formatting (including links and images). Otherwise you may continue editing the question via a web browser.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Warning to users editing an essay question that was edited on the web.")
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                    let cancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Cancel button title")
                    alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in
                        // Nothing to do if they cancel
                    }))

                    let removeFormatting = NSLocalizedString("Remove Formatting", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Remove the formatting of the essay question text")
                    alert.addAction(UIAlertAction(title: removeFormatting, style: .destructive, handler: { action in

                        switch question.answer {
                        case .text(let htmlAnswer):
                            self.submissionInteractor?.selectAnswer(.text(htmlAnswer.stringByStrippingHTML()), forQuestionAtIndex: questionIndex) {}
                            tableView.reloadRows(at: [indexPath], with: .fade)
                        default:
                            break
                        }
                    }))

                    present(alert, animated: true, completion: nil)
                }

            case .ShortAnswer, .Numerical:
                if let cell = tableView.cellForRow(at: indexPath) as? ShortAnswerCell {
                    cell.textField.becomeFirstResponder()
                }

            default:
                break
            }
        default:
            break // you can't touch that
        }
    }

    fileprivate func updateAnswersForQuestionAtIndex(_ questionIndex: Int) {
        let question = questions[questionIndex]

        switch question.question.kind {
        case .MultipleChoice, .MultipleAnswers, .TrueFalse:

            // update all the answer cells
            for answerIndex in 0..<question.question.answers.count {
                let indexPath = Index.answer(question: questionIndex, answer: answerIndex).indexPath

                if let cell = tableView.cellForRow(at: indexPath) {
                    let answer = question.question.answers[answerIndex]
                    updateAnswerForCell(cell as! SelectableAnswerCell, answer: answer, question: question)
                }
            }

        default:
            break
        }
    }

    fileprivate func updateAnswerForCell(_ cell: SelectableAnswerCell, answer: Answer, question: SubmissionQuestion) {
        switch question.answer {
        case .id(let answerID):
            if answer.id == answerID {
                cell.configureForState(selected: true)
            } else {
                cell.configureForState(selected: false)
            }
        case .ids(let answerIDs):
            if answerIDs.contains(answer.id) {
                cell.configureForState(selected: true)
            } else {
                cell.configureForState(selected: false)
            }
        default:
            cell.configureForState(selected: false)
        }
    }

    fileprivate func updateFlagStatusForQuestionAtIndex(_ questionIndex: Int) {
        let question = questions[questionIndex]

        let indexPath = Index.question(question: questionIndex)
        if let headerView = tableView.headerView(forSection: indexPath.indexPath.section) as? QuestionHeaderView {
            updateFlagStatusForHeaderView(headerView, question: question)
        }
    }

    fileprivate func updateFlagStatusForHeaderView(_ view: QuestionHeaderView, question: SubmissionQuestion) {
        view.flagged = question.flagged
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
        switch Index(indexPath: indexPath) {
        case .quizDescription:
            let whizzyCell = cell as! WhizzyWigTableViewCell
            prepareWhizzyCell(whizzyCell, forRowAtIndexPath: indexPath)
            whizzyCell.whizzyWigView.loadHTMLString(quiz?.description ?? "", baseURL: whizzyBaseURL)
            whizzyCell.readMore = { wwvc in
                let nav = UINavigationController(rootViewController: wwvc)
                self.present(nav, animated: true) {
                    wwvc.whizzyWigView.loadHTMLString(self.quiz?.description ?? "", baseURL: self.whizzyBaseURL)
                }
            }
        case .question(question: let questionIndex):
            let whizzyCell = cell as! WhizzyWigTableViewCell
            let question = questions[questionIndex]
            prepareWhizzyCell(whizzyCell, forRowAtIndexPath: indexPath)
            var html = question.question.text
            if question.question.kind == .MultipleAnswers {
                let selectAllString = NSLocalizedString("Select all that apply", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Label indicating that the question is a multiple answer question and more than 1 answer can be correct")
                let multipleAnswerIndicator = String(format: "<p><b>%@</b></p>", selectAllString)
                html = html + multipleAnswerIndicator
            }
            whizzyCell.whizzyWigView.loadHTMLString(html, baseURL: whizzyBaseURL)
        case .answer(question: let questionIndex, answer: let answerIndex):
            let question = questions[questionIndex]
            switch question.question.kind {
            case .MultipleChoice, .TrueFalse, .MultipleAnswers:
                let answerIndex = indexPath.row - 1
                let answer = question.question.answers[answerIndex]
                switch answer.content {
                case .html(let htmlString):
                    let answerCell = cell as! HTMLAnswerCell
                    prepareHTMLAnswerCell(answerCell, forRowAtIndexPath: indexPath)
                    answerCell.whizzyWigView.loadHTMLString(htmlString, baseURL: whizzyBaseURL)
                    updateAnswerForCell(answerCell, answer: answer, question: question)
                case .text(let text):
                    let textCell = cell as! TextAnswerCell
                    textCell.textAnswerLabel.text = text
                    updateAnswerForCell(textCell, answer: answer, question: question)
                }
            case .Matching:
                if let cell = cell as? MatchAnswerCell {
                    let defaultMatchLabel = NSLocalizedString("Select Answer", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Indicates that a matching quiz question needs to have an answer selected")
                    let items = question.question.matches ?? []
                    cell.pickerItems = [defaultMatchLabel] + items.map { $0.text }
                    cell.donePicking = { [weak self] selectionRow in
                        cell.matchLabel.text = cell.pickerItems[selectionRow]
                        if selectionRow == 0 {
                            // if "[No answer]"
                            if let newAnswer = self?.questions[questionIndex].answer.setMatch(question.question.answers[answerIndex].id, matchID: nil) {
                                self?.submissionInteractor?.selectAnswer(newAnswer, forQuestionAtIndex: questionIndex) {}
                            }
                        } else {
                            if let newAnswer = self?.questions[questionIndex].answer.setMatch(question.question.answers[answerIndex].id, matchID: items[selectionRow-1].id) {
                                self?.submissionInteractor?.selectAnswer(newAnswer, forQuestionAtIndex: questionIndex) {}
                            }
                        }
                    }
                    let answer = question.question.answers[answerIndex]
                    switch answer.content {
                    case .text(let text):
                        cell.answerLabel.text = text
                    default:
                        break
                    }
                    cell.matchLabel.text = defaultMatchLabel
                    if let submissionAnswerMatchID = question.answer.matches?[answer.id] {
                        if let match = question.question.matches?.filter({ $0.id == submissionAnswerMatchID})[0] {
                            cell.matchLabel.text = match.text
                        }
                    }

                }
            case .ShortAnswer, .Numerical:
                if let cell = cell as? ShortAnswerCell {
                    cell.textField.text = question.answer.answerText

                    cell.doneEditing = { [weak self] text in
                        self?.submissionInteractor?.selectAnswer(.text(text), forQuestionAtIndex: questionIndex) {}
                    }

                    if question.question.kind == .Numerical {
                        cell.textField.keyboardType = .numbersAndPunctuation
                    }
                }
            default:
                return
            }
        }
    }


    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? EssayAnswerCell {
            cell.textView.resignFirstResponder()
        } else if let cell = cell as? ShortAnswerCell {
            cell.textField.resignFirstResponder()
        }
    }
}


func ==(lhs: SubmissionViewController.Index, rhs: SubmissionViewController.Index) -> Bool {
    switch (lhs, rhs) {
    case (.quizDescription, .quizDescription):
        return true

    case let (.question(leftIndex), .question(rightIndex)):
        return leftIndex == rightIndex

    case let (.answer(leftQ, leftA), .answer(rightQ, rightA)):
        return leftQ == rightQ && leftA == rightA

    default:
        return false
    }
}



private struct EssayResponseCache {
    static func keyForQuestion(_ question: SubmissionQuestion, submission: Submission) -> String {
        return "essay-cache-\(question.question.id).\(submission.id).\(submission.attempt)"
    }

    static func cachedEssayResponseForQuestion(_ question: SubmissionQuestion, ofSubmission submission: Submission) -> String {
        return UserDefaults.standard.object(forKey: keyForQuestion(question, submission: submission)) as? String ?? ""
    }

    static func cacheResponse(_ response: String, forEssayQuestion question: SubmissionQuestion, ofSubmission submission: Submission) {
        UserDefaults.standard.set(response, forKey: keyForQuestion(question, submission: submission))
    }
}
