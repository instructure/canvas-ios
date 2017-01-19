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
    
    

import SoPersistent
import ReactiveSwift
import SoLazy
import Kingfisher
import SoIconic
import SoLazy

open class ConversationTableViewCell: UITableViewCell {
    @IBOutlet open weak var nameTextLabel: UILabel?
    @IBOutlet open weak var subjectTextLabel: UILabel?
    @IBOutlet open weak var dateTextLabel: UILabel?
    @IBOutlet open weak var messageTextLabel: UILabel?
    @IBOutlet open weak var avatarImageView: UIImageView?

    open static var nib: UINib {
        let bundle = Bundle(for: self)
        return UINib(nibName: "ConversationTableViewCell", bundle: bundle)
    }

    open static let reuseIdentifier = "conversation-cell"

    open var viewModel: ConversationViewModel? {
        didSet {
            beginObservingViewModel()
        }
    }

    fileprivate let disposable = CompositeDisposable()

    fileprivate func beginObservingViewModel() {
        guard let vm = viewModel else { return }

        nameTextLabel?.text = vm.displayName
        subjectTextLabel?.text = vm.subject
        dateTextLabel?.text = vm.displayDate
        messageTextLabel?.text = vm.mostRecentMessage
        if let avatarImageView = avatarImageView {
            disposable += avatarImageView.rac_image <~ vm.avatarImage
        }
    }
}

open class ConversationViewModel: TableViewCellViewModel {

    // MARK: TableViewCellViewModel

    open static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(ConversationTableViewCell.nib, forCellReuseIdentifier: ConversationTableViewCell.reuseIdentifier)
    }

    open func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.reuseIdentifier, for: indexPath) as! ConversationTableViewCell
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
    open lazy var displayName: String = {
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
    open lazy var displayDate: String = {
        let date = self.conversation.date
        let currentTime = Clock.currentTime()
        let formatter = date.isTheSameDayAsDate(currentTime) ? self.todayDateFormatter : self.notTodayDateFormatter
        return formatter.string(from: date)
    }()

    /**
     The avatar image of the most recent sender.
     */
    open lazy var avatarImage: Property<UIImage?> = {
        let defaultAvatar = UIImage.icon(.course, filled: true) // TODO: default avatar frd
        let avatar = MutableProperty<UIImage?>(defaultAvatar)
        if let url = URL(string: self.conversation.mostRecentSender.avatarURL) {
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { image, _, _, _ in
                if let image = image {
                    avatar.value = image
                }
            }
        }
        return Property(initial: defaultAvatar, then: avatar.producer)
    }()

    fileprivate let conversation: Conversation
    fileprivate lazy var todayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    fileprivate lazy var notTodayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    // MARK: Initializers

    public init(conversation: Conversation) {
        self.conversation = conversation
    }
}
