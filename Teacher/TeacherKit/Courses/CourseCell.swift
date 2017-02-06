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
    
    

import Foundation
import UIKit
import ReactiveSwift
import EnrollmentKit
import SoIconic

class CourseCell: EnrollmentCollectionViewCell {
    
    @IBOutlet weak var customizeButton: UIButton?
    @IBOutlet weak var announceButtonView: UIView?
    @IBOutlet weak var innerAnnounceButtonView: UIButton?
    @IBOutlet weak var announceButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    var customize: (UIButton)->() = {_ in}
    var makeAnnouncement: ()->() = {}
    
    fileprivate var disposable: CompositeDisposable = CompositeDisposable()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeEvenMoreBeautiful()
        beginObservingProperties()
        makeAccessible()
        announceButton?.setImage(.icon(.announcement), for: .normal)
        customizeButton?.setImage(.icon(.edit, filled: true), for: .normal)
    }
    
    // MARK: Content
    
    func beginObservingProperties() {
        let producer = enrollment.producer
        if let t = titleLabel?.rac_text { t <~ producer.map { $0?.name ?? "" } }
        if let s = subtitleLabel?.rac_text { s <~ producer.map { $0?.shortName ?? "" } }
    }
    
    var viewModel: CourseViewModel? {
        didSet {
            customize = {_ in }
            makeAnnouncement = {}
            enrollment.value = viewModel?.enrollment.value
            
            if let vm = viewModel {
                customize = vm.customize
                makeAnnouncement = vm.makeAnAnnouncement
            }
        }
    }
    
    // MARK: Appearance
    
    func makeEvenMoreBeautiful() {
        announceButton?.setImage(.icon(.announcement), for: .normal)
        announceButtonView?.layer.cornerRadius = 21
        innerAnnounceButtonView?.layer.cornerRadius = 19
        innerAnnounceButtonView?.backgroundColor = .white
        tintColor = .white
        layer.borderWidth = 2.0
        if let a = announceButtonView { contentView.bringSubview(toFront: a) }
    }
    
    override func colorUpdated(_ color: UIColor) {
        super.colorUpdated(color)
        announceButtonView?.backgroundColor = color
        layer.borderColor = color.cgColor
        innerAnnounceButtonView?.tintColor = color
    }
    
    
    // MARK: A11y
    
    func makeAccessible() {
        accessibilityElements = []
        
        isAccessibilityElement = true
        rac_a11yLabel <~ enrollment.producer.map { ($0?.name ?? "") + " — " + ($0?.shortName ?? "") }
        
        let announceTitle = NSLocalizedString("Make an Announcement", comment: "Make an announcement accessiblity text")
        let announceAction = UIAccessibilityCustomAction(name: announceTitle, target: self, selector: #selector(makeAnAnnouncement(_:)))
        
        let customizeTitle = NSLocalizedString("Customize", comment: "Customize course action title")
        let customizeAction = UIAccessibilityCustomAction(name: customizeTitle, target: self, selector: #selector(customizeCourse(_:)))
        
        accessibilityCustomActions = [announceAction, customizeAction]
    }

    
    // MARK: Actions
    
    @IBAction func customizeCourse(_ sender: AnyObject) {
        if let button = customizeButton {
            customize(button)
        }
    }
    
    @IBAction func makeAnAnnouncement(_ sender: AnyObject) {
        makeAnnouncement()
    }
}
