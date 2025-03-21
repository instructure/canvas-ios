//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

protocol MasteryPathDelegate: AnyObject {
    func didSelectMasteryPath(id: String, inModule moduleID: String, item itemID: String)
}

class MasteryPathViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    let env = AppEnvironment.shared
    var masteryPath: MasteryPath!
    var selectedSetID: String?
    weak var delegate: MasteryPathDelegate?

    static func create(masteryPath: MasteryPath) -> MasteryPathViewController {
        let controller = loadFromStoryboard()
        controller.masteryPath = masteryPath
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = String(localized: "Select a Path", bundle: .core)
        let sets = masteryPath.assignmentSets.sorted { $0.position < $1.position }
        for (index, set) in sets.enumerated() {
            if index > 0 {
                let or = MasteryPathAssignmentSetDivider()
                or.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(or)
            }
            let setView = MasteryPathAssignmentSetView(set: set)
            setView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(setView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onSelectedAssignment(_:)), name: .masteryPathAssignmentSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSelectedSet(_:)), name: .masteryPathSelected, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // deselect selected row
        NotificationCenter.default.post(name: .masteryPathAssignmentSelected, object: nil, userInfo: [:])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // notify delegate when Back triggered
        let isGoingBack = navigationController?.viewControllers.contains(self) == false
        if isGoingBack, let selectedSetID = selectedSetID,
            let item = masteryPath.moduleItem,
            let itemID = item.moduleItem?.id {
            delegate?.didSelectMasteryPath(id: selectedSetID, inModule: item.moduleID, item: itemID)
        }
    }

    @objc func onSelectedSet(_ notification: Notification) {
        let id = notification.userInfo?["id"] as? String
        if id == selectedSetID {
            NotificationCenter.default.post(name: .masteryPathSelected, object: nil, userInfo: [:])
        } else {
            selectedSetID = id
        }
    }

    @objc func onSelectedAssignment(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String,
            let courseID = masteryPath.moduleItem?.courseID
        else { return }
        env.router.route(to: "/courses/\(courseID)/assignments/\(id)", from: self, options: .detail)
    }
}

class MasteryPathAssignmentSetView: UIView {
    let stackView = UIStackView()
    let set: MasteryPathAssignmentSet

    init(set: MasteryPathAssignmentSet) {
        self.set = set
        super.init(frame: .zero)
        layer.borderWidth = 1
        layer.borderColor = UIColor.borderMedium.cgColor
        layer.cornerRadius = 12
        backgroundColor = .borderMedium
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.pin(inside: self)
        stackView.axis = .vertical
        stackView.spacing = 0.5
        for assignment in set.assignments.sorted(by: { $0.position < $1.position }) {
            let cell = MasteryPathAssignmentCell(assignment: assignment)
            cell.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(cell)
        }
        let select = MasteryPathAssignmentSetSelectCell(id: set.id)
        select.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(select)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MasteryPathAssignmentCell: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    let assignment: MasteryPathAssignment

    init(assignment: MasteryPathAssignment) {
        self.assignment = assignment
        super.init(frame: .zero)
        loadFromXib()
        backgroundColor = .backgroundLightest
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tap)
        accessibilityTraits.insert(.button)
        NotificationCenter.default.addObserver(self, selector: #selector(onAssignmentSelected(_:)), name: .masteryPathAssignmentSelected, object: nil)
        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        nameLabel.text = assignment.name
        if let pointsPossible = assignment.pointsPossible?.doubleValue {
            pointsLabel.isHidden = false
            pointsLabel.text = String.localizedStringWithFormat(String(localized: "g_points", bundle: .core), pointsPossible)
        } else {
            pointsLabel.isHidden = true
        }
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .masteryPathAssignmentSelected, object: nil, userInfo: ["id": assignment.id])
    }

    @objc func onAssignmentSelected(_ notification: Notification) {
        setSelected(notification.userInfo?["id"] as? String == assignment.id)
    }

    func setSelected(_ selected: Bool) {
        if selected {
            backgroundColor = .backgroundLight
            accessibilityTraits.insert(.selected)
        } else {
            UIView.animate(withDuration: 0.25) { self.backgroundColor = .backgroundLightest }
            accessibilityTraits.remove(.selected)
        }
    }
}

class MasteryPathAssignmentSetSelectCell: UIView {
    let button = UIButton()
    let id: String
    private let offlineModeInteractor: OfflineModeInteractor

    init(id: String, offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()) {
        self.id = id
        self.offlineModeInteractor = offlineModeInteractor
        super.init(frame: .zero)
        backgroundColor = .backgroundLightest
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.pin(inside: self, leading: 16, trailing: 16, top: 16, bottom: 16)
        button.layer.cornerRadius = 4

        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outcoming = incoming
            outcoming.font = UIFont.scaledNamedFont(.semibold16)
            return outcoming
        }
        button.configuration = config

        button.addTarget(self, action: #selector(onSelect(_:)), for: .primaryActionTriggered)
        button.makeUnavailableInOfflineMode(offlineModeInteractor)
        update(selected: false)
        NotificationCenter.default.addObserver(self, selector: #selector(onMasteryPathSelected(_:)), name: .masteryPathSelected, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(selected: Bool) {
        button.layer.borderColor = selected ? UIColor.borderMedium.cgColor : Brand.shared.buttonPrimaryBackground.cgColor
        button.layer.borderWidth = selected ? 1 : 0
        button.backgroundColor = selected ? .clear : Brand.shared.buttonPrimaryBackground
        button.setTitleColor(selected ? .textDark : Brand.shared.buttonPrimaryText, for: .normal)
        button.setTitleColor(.textDark, for: .highlighted)
        let title = selected ? String(localized: "Selected!", bundle: .core) : String(localized: "Select", bundle: .core)
        button.setTitle(title, for: .normal)
    }

    @objc func onSelect(_ sender: UIButton) {
        NotificationCenter.default.post(name: .masteryPathSelected, object: nil, userInfo: ["id": id])
    }

    @objc func onMasteryPathSelected(_ notification: Notification) {
        update(selected: notification.userInfo?["id"] as? String == id)
    }
}

class MasteryPathAssignmentSetDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib().backgroundColor = .backgroundLightest
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib().backgroundColor = .backgroundLightest
    }
}

extension Notification.Name {
    fileprivate static let masteryPathSelected = Notification.Name(rawValue: "com.instructure.core.notification.masteryPathSelected")
    fileprivate static let masteryPathAssignmentSelected = Notification.Name("com.instructure.core.notification.masteryPathAssignmentSelected")
}
