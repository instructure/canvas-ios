//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import AFNetworking
import Core

extension Status {
    var subtitle: (label: String, tint: UIColor) {
        guard let attendance = attendance else { return ("", .white) }
        
        switch attendance {
        case .present: return (NSLocalizedString("Present", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), UIColor.named(.backgroundSuccess))
        case .late: return (NSLocalizedString("Late", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), UIColor.named(.backgroundWarning))
        case .absent: return (NSLocalizedString("Absent", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), UIColor.named(.backgroundDanger))
        }
    }
    
    var icon: UIImage {
        guard let attendance = attendance else { return UIImage(named: "unmarked-icon", in: .core, compatibleWith: nil)! }
        
        switch attendance {
        case .present: return UIImage(named: "present-icon", in: .core, compatibleWith: nil)!
        case .late: return UIImage(named: "late-icon", in: .core, compatibleWith: nil)!
        case .absent: return UIImage(named: "absent-icon", in: .core, compatibleWith: nil)!
        }
    }
}

class StatusCell: UITableViewCell {
    @objc static let reuseID = "StatusCell"
    
    @objc let avatarView = AvatarView()
    @objc let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .named(.backgroundLightest)

        nameLabel.font = .scaledNamedFont(.semibold16)
        nameLabel.textColor = .named(.textDarkest)
        
        let vertStack = UIStackView()
        vertStack.axis = .vertical
        vertStack.alignment = .leading
        vertStack.addArrangedSubview(nameLabel)
        
        let horizontalStack = UIStackView()
        horizontalStack.alignment = .center
        horizontalStack.spacing = 8
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(avatarView)
        horizontalStack.addArrangedSubview(vertStack)
        
        let guide = contentView.layoutMarginsGuide
        contentView.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            guide.leadingAnchor.constraint(equalTo: horizontalStack.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor),
            guide.topAnchor.constraint(equalTo: horizontalStack.topAnchor),
            guide.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not IB Friendly #sorrynotsorry")
    }
    
    var status: Status? {
        didSet {
            guard let status = status else { return }
            nameLabel.text = status.student.name
            var i18nLabel = status.student.name
            if status.attendance != nil {
                i18nLabel += " — \(status.subtitle.label)"
            }
            accessibilityLabel = i18nLabel

            avatarView.name = status.student.name
            avatarView.url = status.student.avatarURL
            
            accessoryView = UIImageView(image: status.icon)
        }
    }
}
