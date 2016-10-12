//
//  ConversationTableViewCell.swift
//  Messages
//
//  Created by Nathan Armstrong on 7/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent
import ReactiveCocoa
import SoLazy
import Kingfisher
import SoIconic
import SoLazy

public class ConversationTableViewCell: UITableViewCell {
    @IBOutlet public weak var nameTextLabel: UILabel?
    @IBOutlet public weak var subjectTextLabel: UILabel?
    @IBOutlet public weak var dateTextLabel: UILabel?
    @IBOutlet public weak var messageTextLabel: UILabel?
    @IBOutlet public weak var avatarImageView: UIImageView?

    public static var nib: UINib {
        let bundle = NSBundle(forClass: self)
        return UINib(nibName: "ConversationTableViewCell", bundle: bundle)
    }

    public static let reuseIdentifier = "conversation-cell"

    public var viewModel: ConversationViewModel? {
        didSet {
            beginObservingViewModel()
        }
    }

    private let disposable = CompositeDisposable()

    private func beginObservingViewModel() {
        guard let vm = viewModel else { return }

        nameTextLabel?.text = vm.displayName
        subjectTextLabel?.text = vm.subject
        dateTextLabel?.text = vm.displayDate
        messageTextLabel?.text = vm.mostRecentMessage
        disposable += (avatarImageView?.rac_image).map { $0 <~ vm.avatarImage }
    }
}

public class ConversationViewModel: TableViewCellViewModel {

    // MARK: TableViewCellViewModel

    public static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(ConversationTableViewCell.nib, forCellReuseIdentifier: ConversationTableViewCell.reuseIdentifier)
    }

    public func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ConversationTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! ConversationTableViewCell
        cell.viewModel = self
        return cell
    }

    // MARK: Outputs

    /**
     The name of the receiving participant in the conversation.
     
     If there is more than one participant, it is the name of the most recent sender
     followed by the count of the other participants.
     
     Example: Bianca Pascellita, +5
     */
    public lazy var displayName: String = {
        let mostRecentSender = self.conversation.mostRecentSender.name
        guard self.conversation.numberOfParticipants > 1 else {
            return mostRecentSender
        }

        return String(format: "%@, +%d", mostRecentSender, self.conversation.numberOfParticipants - 1)
    }()

    /**
     The subject of the conversation.
     */
    var subject: String {
        return conversation.subject
    }

    /**
     The content of the most recent message.
     */
    var mostRecentMessage: String {
        return conversation.mostRecentMessage
    }

    /**
     The formatted date of the most recent message.
     */
    public lazy var displayDate: String = {
        let date = self.conversation.date
        let currentTime = Clock.currentTime()
        let formatter = date.isTheSameDayAsDate(currentTime) ? self.todayDateFormatter : self.notTodayDateFormatter
        return formatter.stringFromDate(date)
    }()

    /**
     The avatar image of the most recent sender.
     */
    public lazy var avatarImage: AnyProperty<UIImage?> = {
        let defaultAvatar = UIImage.icon(.course, filled: true) // TODO: default avatar frd
        let avatar = MutableProperty<UIImage?>(defaultAvatar)
        if let url = NSURL(string: self.conversation.mostRecentSender.avatarURL) {
            KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil) { image, _, _, _ in
                if let image = image {
                    avatar.value = image
                }
            }
        }
        return AnyProperty(initialValue: defaultAvatar, producer: avatar.producer)
    }()

    private let conversation: Conversation
    private lazy var todayDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    private lazy var notTodayDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    // MARK: Initializers

    public init(conversation: Conversation) {
        self.conversation = conversation
    }
}
