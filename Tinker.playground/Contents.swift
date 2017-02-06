//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true


import SoPretty
import SoPersistent
import SoIconic
import Cartography
import CoreGraphics
import QuartzCore
import SoLazy
import ReactiveSwift

class GradientView: UIView {
    var colors: [UIColor] = [] {
        didSet {
            gradient.colors = colors.map { $0.cgColor }
        }
    }

    var direction: (start: CGPoint, end: CGPoint) = (.zero, .zero) {
        didSet {
            gradient.startPoint = self.direction.start
            gradient.endPoint = self.direction.end
        }
    }

    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        self.layer.addSublayer(gradient)

        return gradient
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }
}

class FileUploadCell: UITableViewCell {

    // Icon
    let iconImageView = UIImageView()

    // Labels
    let nameLabel = UILabel()
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()
    lazy var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1

        stack.addArrangedSubview(self.nameLabel)
        stack.addArrangedSubview(self.statusLabel)

        return stack
    }()

    // Actions
    let errorInfoButton = UIButton(type: .infoLight)
    let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setContentHuggingPriority(1000, for: .horizontal)
        return btn
    }()
    lazy var actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12

        stack.addArrangedSubview(self.errorInfoButton)
        stack.addArrangedSubview(self.actionButton)

        return stack
    }()

    // Progress
    let progressView: GradientView = {
        let view = GradientView()
        let left = UIColor(r: 0, g: 142, b: 226)
        let right = UIColor(r: 0, g: 193, b: 243)
        view.colors = [left, right]
        view.direction = (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        return view
    }()
    var progressWidthConstraint: NSLayoutConstraint!
    var progress: Int = 0 { // 0-100
        didSet {
            NSLayoutConstraint.deactivate([progressWidthConstraint])
            progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.01 * CGFloat(progress))
            NSLayoutConstraint.activate([progressWidthConstraint])
        }
    }

    // Constants
    let iconSize: CGFloat = 24
    let progressHeight: CGFloat = 4
    let minimumProgress = 5

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Progress
        contentView.addSubview(progressView)
        progressView.heightAnchor.constraint(equalToConstant: progressHeight).isActive = true
        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0)
        progressWidthConstraint.isActive = true
        constrain(progressView, contentView) { progressView, contentView in
            progressView.bottom == contentView.bottom
            progressView.leading == contentView.leading
        }

        // Icon
        contentView.addSubview(iconImageView)
        iconImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        constrain(iconImageView, contentView) { icon, contentView in
            icon.leading == contentView.leadingMargin
            icon.centerY == contentView.centerY
        }

        // Actions
        contentView.addSubview(actionStack)
        actionStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        constrain(actionStack, contentView) { actionStack, contentView in
            actionStack.trailing == contentView.trailingMargin
        }

        // Labels
        contentView.addSubview(labelStack)
        constrain(labelStack, contentView) { labelStack, contentView in
            labelStack.top == contentView.topMargin
        }
        constrain(labelStack, progressView) { labelStack, progressView in
            distribute(by: 10, vertically: labelStack, progressView)
        }

        constrain(iconImageView, labelStack, actionStack) { iconImageView, labelStack, actionStack in
            distribute(by: 10, horizontally: iconImageView, labelStack, actionStack)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum FileUploadState {
    case failed
    case stopped
    case inProgress(Int)
    case complete
}

enum ContentType {
    case docx
    case jpg
    case pdf
    case eml
    case html

    var image: UIImage {
        return .icon(.file)
    }
}

struct Row {
    let contentType: ContentType
    let name: String
    let state: FileUploadState

    init(_ name: String, _ contentType: ContentType, _ state: FileUploadState) {
        self.name = name
        self.contentType = contentType
        self.state = state
    }
}

let rows: [Row] = [
    Row("Americanbiologicalfile.docx", .docx, .failed),
    Row("applicationfiles.jpg", .jpg, .stopped),
    Row("anotherfilename.pdf", .pdf, .inProgress(60)),
    Row("B-terms.pages", .docx, .inProgress(0)),
    Row("biology.psd", .jpg, .inProgress(45)),
    Row("biologypapers.ai", .jpg, .inProgress(75)),
    Row("CatfishEmail.eml", .eml, .inProgress(10)),
    Row("code-applicationtodmoreandmoreandmoreandmore.html", .html, .complete)
]

class Pretty: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "File Uploads"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.isEnabled = false

        tableView.register(FileUploadCell.self, forCellReuseIdentifier: "fileuploadcell")
        // ColorfulViewModel.tableViewDidLoad(tableView)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileuploadcell") as! FileUploadCell
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.nameLabel.text = rows[indexPath.row].name
        cell.iconImageView.image = rows[indexPath.row].contentType.image

        cell.errorInfoButton.isHidden = true
        cell.actionButton.setImage(.icon(.file), for: .normal)

        switch rows[indexPath.row].state {
        case .inProgress(let progress):
            cell.progressView.isHidden = false
            cell.progress = max(cell.minimumProgress, progress)
            cell.statusLabel.text = "uploading..."
            cell.actionButton.setImage(.icon(.file), for: .normal)
        case .failed:
            cell.progress = 0
            cell.statusLabel.text = "Failed"
            cell.errorInfoButton.isHidden = false
        case .complete:
            cell.progress = 0
            cell.statusLabel.text = "Complete"
        case .stopped:
            cell.progress = 0
            cell.statusLabel.text = "Stopped"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add File...", for: .normal)
        return addButton
    }
}


let nav = UINavigationController(rootViewController: Pretty())
nav.navigationBar.barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)

let tabs = UITabBarController()
tabs.viewControllers = [nav]
page.liveView = tabs
