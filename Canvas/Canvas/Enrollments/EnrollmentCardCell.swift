//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import EnrollmentKit
import Result
import ReactiveSwift
import ReactiveCocoa
import SoLazy
import SoPersistent
import TooLegit

class CustomA11yActionBarButton: UIBarButtonItem {
    var customAction: CocoaAction<UIAccessibilityCustomAction>?
}

extension Enrollment {
    var gradeButtonTitle: String {
        let grades: String = [visibleGrade, visibleScore]
            .flatMap( { $0 } )
            .joined(separator: "   ")

        if grades != "" {
            return grades
        }
        
        return NSLocalizedString("Ungraded", comment: "Title for grade button when no grade is present")
    }
}

class EnrollmentCardCell: EnrollmentCollectionViewCell {
    
    var customize: ()->() = {}
    var showGrades: ()->() = {}
    var takeShortcut: (URL)->() = { _ in }
    var handleError: (NSError)->() = { _ in }

    var disposable: CompositeDisposable?
    var toolbarButtons: [UIBarButtonItem]?
    
    fileprivate var shortcutsDisposable: Disposable?
    var shortcutsCollection: FetchedCollection<Tab>? {
        didSet {
            shortcutsDisposable = shortcutsCollection?.collectionUpdates
                .observe(on: UIScheduler())
                .observeValues { [weak self] _ in
                    if let me = self {
                        me.updateShortcuts()
                    }
                }.map(ScopedDisposable.init)
            updateShortcuts()
        }
    }
    
    lazy var shortcutAction: Action<URL, Void, NoError> = { url in
        return Action() { [weak self] url in
            self?.takeShortcut(url)
            return .empty
        }
    }()
    
    func updateShortcuts() {
        let leadingSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarButtons = shortcutsCollection?.map { tab in
            
            let button = CustomA11yActionBarButton(image: tab.shortcutIcon, landscapeImagePhone: nil, style: .plain, target: nil, action: nil)
            button.accessibilityLabel = tab.label
            
            button.reactive.pressed = CocoaAction(shortcutAction, input: tab.url)
            button.customAction = CocoaAction(shortcutAction, input: tab.url)

            return button
        }
        toolbar?.items = toolbarButtons?.reduce([leadingSpace]) { items, button in
            return (items ?? []) + [
                button,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ]
        }

        updateA11y()
    }
    
    var viewModel: EnrollmentCardViewModel? {
        didSet {
            disposable?.dispose()
            disposable = CompositeDisposable()
            shortcutsCollection = nil
            customize = {}
            showGrades = {}

            if let vm = viewModel {
                customize = vm.customize
                showGrades = vm.showGrades
                takeShortcut = vm.takeShortcut
                handleError = vm.handleError
                if let d = disposable {
                    let producer = vm.enrollment.producer
                    let gradebuttonTitle = producer.map { $0?.gradeButtonTitle }
                    let a11yGradeButtonTitle = gradebuttonTitle.map { $0?.replacingOccurrences(of: "-", with: " minus") }
                    d += enrollment <~ vm.enrollment
                    d += titleLabel.rac_text <~ producer.map { $0?.name ?? "" }
                    if let shortNameLabel = shortNameLabel {
                        d += shortNameLabel.rac_text <~ producer.map { $0?.shortName ?? ""}
                    }
                    if let gradeButton = gradeButton {
                        d += gradeButton.rac_title <~ gradebuttonTitle
                        d += gradeButton.rac_a11yLabel <~ a11yGradeButtonTitle
                        d += gradeButton.rac_hidden <~ vm.showingGrades.producer.map(!)
                    }
                    d += self.rac_a11yHint <~ gradebuttonTitle
                }
                
                do {
                    if let contextID = vm.enrollment.value?.contextID, case .course = contextID.context {
                        shortcutsCollection = try Tab.shortcuts(vm.session, contextID: contextID)
                    }
                } catch let e as NSError {
                    handleError(e)
                }
            }

            updateA11y()
        }
    }

    func updateA11y() {
        self.accessibilityLabel = "\(titleLabel?.text ?? ""): \(shortNameLabel?.text ?? "")"

        self.accessibilityCustomActions = [UIAccessibilityCustomAction(name: "Grades", target: self, selector: #selector(showGrades(_:)))]
        if let shortcuts = toolbarButtons {
            for shortcut in shortcuts {
                if let shortcutLabel = shortcut.accessibilityLabel, let customActionButton = shortcut as? CustomA11yActionBarButton {
                    accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: shortcutLabel, target: customActionButton.customAction, selector: CocoaAction<UIAccessibilityCustomAction>.selector))
                }
            }
        }
        accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: "Customize", target: self, selector: #selector(customizedTapped(_:))))
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shortNameLabel: UILabel?
    @IBOutlet weak var gradeButton: UIButton?
    @IBOutlet weak var customizeButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        makeEvenMoreBeautiful()
        
        enrollment.producer
            .startWithValues { [weak self] enrollment in
                self?.refresh(enrollment)
        }

        self.isAccessibilityElement = true
    }
    
    func makeEvenMoreBeautiful() {
        layer.borderWidth = 1
        
        toolbar?.backgroundColor = .white
        toolbar?.clipsToBounds = true
        
        customizeButton.tintColor = .white
        
        gradeButton?.layer.cornerRadius = 8
    }
    
    func refresh(_ enrollment: Enrollment?) {
        titleLabel.text = enrollment?.name
        
        shortNameLabel?.text = enrollment?.shortName
        
        let grade = [enrollment?.visibleGrade, enrollment?.visibleScore]
            .flatMap { $0 }
            .joined(separator: "  ")
        
        let title = (grade == "") ? NSLocalizedString("Unavailable", comment: "Grade unavailable") : grade
        
        gradeButton?.setTitle(title, for: .normal)
    }
    
    override func colorUpdated(_ color: UIColor) {
        super.colorUpdated(color)
        layer.borderColor = color.cgColor
        gradeButton?.tintColor = color
        toolbar?.tintColor = color
    }
}

extension EnrollmentCardCell {
    
    @IBAction func customizedTapped(_ sender: Any) {
        customize()
    }
    
    @IBAction func showGrades(_ sender: Any) {
        showGrades()
    }
}
