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
import Core

enum AddObserveeMethod: Int, CaseIterable, CustomStringConvertible {
    case qr, pairingCode

    var description: String {
        switch self {
        case .qr: return NSLocalizedString("QR Code", comment: "")
        case .pairingCode: return NSLocalizedString("Pairing Code", comment: "")
        }
    }
}

protocol AddStudentMethodProtocol: AnyObject {
    func didSelectAddStudentMethod(method: AddObserveeMethod)
}

class SelectAddStudentMethodViewController: UITableViewController {

    weak var delegate: AddStudentMethodProtocol?

    static func create(delegate: AddStudentMethodProtocol?) -> SelectAddStudentMethodViewController {
        let controller = SelectAddStudentMethodViewController()
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = BottomSheetTransitioningDelegate.shared
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        view.frame.size.height = 175
        tableView.registerCell(UITableViewCell.self)
        tableView.estimatedRowHeight = 62
        tableView.rowHeight = UITableView.automaticDimension

        let header = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let headerLabel = UILabel()
        headerLabel.font = UIFont.scaledNamedFont(.semibold14)
        headerLabel.textColor = .named(.textDark)
        headerLabel.text = NSLocalizedString("Add student with...", comment: "")
        headerLabel.sizeToFit()
        headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25).isActive = true
        headerLabel.numberOfLines = 0
        header.addSubview(headerLabel)
        headerLabel.pin(inside: header, leading: 16, trailing: 16, top: 12, bottom: 8)
        tableView.tableHeaderView = header
        tableView.tableFooterView =  UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddObserveeMethod.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(for: indexPath)
        guard let row = AddObserveeMethod(rawValue: indexPath.row) else { fatalError("Invalid row") }
        cell.textLabel?.text = row.description
        cell.textLabel?.font = .scaledNamedFont(.medium16)
        cell.textLabel?.textColor = .named(.textDarkest)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let method = AddObserveeMethod(rawValue: indexPath.row) else { return }
        delegate?.didSelectAddStudentMethod(method: method)
    }
}
