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

import ReactiveSwift



class TextEntrySubmissionViewController: UITableViewController {
    var text: Property<String?> {
        return Property(_text)
    }
    fileprivate let _text = MutableProperty<String?>(nil)
    fileprivate let textCellHeight = MutableProperty<CGFloat>(100)
    @objc let textCellReuseIdentifier = "TextCell"

    @objc var didFinishEnteringText: ((String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextCell.classForCoder(), forCellReuseIdentifier: textCellReuseIdentifier)

        textCellHeight.producer.startWithValues { [weak self] _ in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }

        let submitTitle = NSLocalizedString("Submit", tableName: "Localizable", bundle: .core, value: "", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: submitTitle, style: .plain, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        tableView.tableFooterView = UIView()
    }

    @objc func done() {
        dismiss(animated: true) {
            self.didFinishEnteringText?(self.text.value)
        }
    }

    @objc func cancel() {
        dismiss(animated: true)
    }
}

extension TextEntrySubmissionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell") as! TextCell
        cell.placeholder.text = NSLocalizedString("Enter your submission...", tableName: "Localizable", bundle: .core, value: "", comment: "Prompt for text upload")
        cell.textView.text = _text.value
        cell.heightDidChange = { [weak self] height in
            self?.textCellHeight.value = height
        }
        cell.textDidChange = { [weak self] text in
            self?._text.value = text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return textCellHeight.value
    }
}

class TextCell: WhizzyTextInputCell {

    @objc override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        textView.backgroundColor = .clear
        
        separatorInset = UIEdgeInsets(top: 0, left: 2000, bottom: 0, right: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Registered by class... so don't do this")
    }
}
