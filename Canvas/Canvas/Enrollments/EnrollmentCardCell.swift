//
//  EnrollmentCardCell.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import EnrollmentKit
import ReactiveCocoa
import SoLazy
import SoPersistent
import TooLegit

extension Enrollment {
    var gradeButtonTitle: String {
        let grades: String = [visibleGrade, visibleScore]
            .flatMap( { $0 } )
            .joinWithSeparator("   ")

        if grades != "" {
            return grades
        }
        
        return NSLocalizedString("Ungraded", comment: "Title for grade button when no grade is present")
    }
}

class EnrollmentCardCell: EnrollmentCollectionViewCell {
    
    var customize: ()->() = {}
    var showGrades: ()->() = {}
    var takeShortcut: NSURL->() = { _ in }
    var handleError: NSError->() = { _ in }

    var disposable: CompositeDisposable?
    var toolbarButtons: [UIBarButtonItem]?
    
    var refresher: Refresher? {
        didSet {
            refresher?.refreshingCompleted.observeNext { [weak self] error in
                guard let e = error else { return }
                self?.handleError(e)
            }
            refresher?.refresh(false)
        }
    }
    var shortcutsCollection: FetchedCollection<Tab>? {
        didSet {
            oldValue?.collectionUpdated = {_ in }
            shortcutsCollection?.collectionUpdated = { [weak self] _ in
                if let me = self {
                    me.updateShortcuts()
                }
            }
            updateShortcuts()
        }
    }
    
    func updateShortcuts() {
        let leadingSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbarButtons = shortcutsCollection?.map { tab in
            
            let button = UIBarButtonItem(image: tab.shortcutIcon, landscapeImagePhone: nil, style: .Plain, target: nil, action: nil)
            button.accessibilityLabel = tab.label
            
            button.rac_command = RACCommand() { [weak self] _ in
                self?.takeShortcut(tab.url)
                return RACSignal.empty()
            }

            return button
        }
        toolbar?.items = toolbarButtons?.reduce([leadingSpace]) { items, button in
            return (items ?? []) + [
                button,
                UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            ]
        }

        updateA11y()
    }
    
    var viewModel: EnrollmentCardViewModel? {
        didSet {
            disposable?.dispose()
            disposable = CompositeDisposable()
            refresher = nil
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
                    let a11yGradeButtonTitle = gradebuttonTitle.map { $0?.stringByReplacingOccurrencesOfString("-", withString: " minus") }
                    d += enrollment <~ vm.enrollment
                    d += titleLabel.rac_text <~ producer.map { $0?.name ?? "" }
                    d += (shortNameLabel?.rac_text).map { $0 <~ producer.map { $0?.shortName ?? "" } }
                    d += (gradeButton?.rac_title).map { $0 <~ gradebuttonTitle }
                    d += self.rac_a11yHint <~ gradebuttonTitle
                    d += (gradeButton?.rac_a11yLabel).map { $0 <~ a11yGradeButtonTitle }
                    d += (gradeButton?.rac_hidden).map { $0 <~ vm.showingGrades.producer.map(!) }
                }
                
                do {
                    if let contextID = vm.enrollment.value?.contextID, case .Course = contextID.context {
                        refresher = try Tab.refresher(vm.session, contextID: contextID)
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
                if let shortcutLabel = shortcut.accessibilityLabel {
                    accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: shortcutLabel, target: shortcut, selector: shortcut.action))
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
            .startWithNext { [weak self] enrollment in
                self?.refresh(enrollment)
        }

        self.isAccessibilityElement = true
    }
    
    func makeEvenMoreBeautiful() {
        layer.borderWidth = 1
        
        toolbar?.backgroundColor = .whiteColor()
        toolbar?.clipsToBounds = true
        
        customizeButton.tintColor = .whiteColor()
        
        gradeButton?.layer.cornerRadius = 8
    }
    
    func refresh(enrollment: Enrollment?) {
        titleLabel.text = enrollment?.name
        
        shortNameLabel?.text = enrollment?.shortName
        
        let grade = [enrollment?.visibleGrade, enrollment?.visibleScore]
            .flatMap { $0 }
            .joinWithSeparator("  ")
        
        let title = (grade == "") ? NSLocalizedString("Unavailable", comment: "Grade unavailable") : grade
        
        gradeButton?.setTitle(title, forState: .Normal)
    }
    
    override func colorUpdated(color: UIColor) {
        super.colorUpdated(color)
        layer.borderColor = color.CGColor
        gradeButton?.tintColor = color
        toolbar?.tintColor = color
    }
}

extension EnrollmentCardCell {
    
    @IBAction func customizedTapped(sender: AnyObject) {
        customize()
    }
    
    @IBAction func showGrades(sender: AnyObject) {
        showGrades()
    }
}
