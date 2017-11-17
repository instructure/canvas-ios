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
import AFNetworking

extension Status {
    var subtitle: (label: String, tint: UIColor) {
        guard let attendance = attendance else { return ("", .white) }
        
        switch attendance {
        case .present: return (NSLocalizedString("Present", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), #colorLiteral(red: 0, green: 0.6745098039, blue: 0.09411764706, alpha: 1))
        case .late: return (NSLocalizedString("Late", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), #colorLiteral(red: 0.9882352941, green: 0.368627451, blue: 0.07450980392, alpha: 1))
        case .absent: return (NSLocalizedString("Absent", tableName: "Localizable", bundle: .core, value: "", comment: "Student is present in class"), #colorLiteral(red: 0.9333333333, green: 0.02352941176, blue: 0.07058823529, alpha: 1))
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
    static let reuseID = "StatusCell"
    
    let avatarImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
    let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        avatarImage.layer.cornerRadius = 20
        avatarImage.clipsToBounds = true
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        nameLabel.textColor = #colorLiteral(red: 0.1764705882, green: 0.231372549, blue: 0.2705882353, alpha: 1)
        
        let vertStack = UIStackView()
        vertStack.axis = .vertical
        vertStack.alignment = .leading
        vertStack.addArrangedSubview(nameLabel)
        
        let horizontalStack = UIStackView()
        horizontalStack.alignment = .center
        horizontalStack.spacing = 8
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(avatarImage)
        horizontalStack.addArrangedSubview(vertStack)
        
        let guide = contentView.layoutMarginsGuide
        contentView.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            avatarImage.widthAnchor.constraint(equalToConstant: 40),
            avatarImage.heightAnchor.constraint(equalToConstant: 40),
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
            
            avatarImage.image = UIImage(named: "People", in: .core, compatibleWith: nil)
            if let avatar = status.student.avatarURL {
                avatarImage.setImageWith(avatar)
            }
            
            accessoryView = UIImageView(image: status.icon)
        }
    }
}
