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


import ReactiveSwift



class TextEntrySubmissionViewController: UITableViewController {
    var text: Property<String?> {
        return Property(_text)
    }
    fileprivate let _text = MutableProperty<String?>(nil)
    fileprivate let textCellHeight = MutableProperty<CGFloat>(100)
    let textCellReuseIdentifier = "TextCell"

    var didFinishEnteringText: ((String?) -> Void)?

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

    func done() {
        dismiss(animated: true) {
            self.didFinishEnteringText?(self.text.value)
        }
    }

    func cancel() {
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        textView.backgroundColor = .clear
        
        separatorInset = UIEdgeInsets(top: 0, left: 2000, bottom: 0, right: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Registered by class... so don't do this"
    }
}
