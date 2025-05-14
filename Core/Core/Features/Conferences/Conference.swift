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

import CoreData
import UIKit

public final class Conference: NSManagedObject {
    @NSManaged var canvasContextID: String
    @NSManaged var conferenceKey: String?
    @NSManaged var conferenceType: String
    @NSManaged var details: String
    @NSManaged var durationRaw: NSNumber? // minutes
    @NSManaged var endedAt: Date?
    @NSManaged var id: String
    @NSManaged var isConcluded: Bool
    @NSManaged var isIgnored: Bool
    @NSManaged var isLive: Bool
    @NSManaged var isLongRunning: Bool
    @NSManaged var joinURL: URL?
    @NSManaged var order: String
    @NSManaged var recordingsRaw: NSOrderedSet?
    @NSManaged var startedAt: Date?
    @NSManaged var title: String
    @NSManaged var url: URL?

    var context: Context {
        get { Context(canvasContextID: canvasContextID) ?? .currentUser }
        set { canvasContextID = newValue.canvasContextID }
    }

    var duration: Double? {
        get { durationRaw?.doubleValue }
        set { durationRaw = NSNumber(value: newValue) }
    }

    var recordings: [ConferenceRecording]? {
        get { recordingsRaw?.array as? [ConferenceRecording] }
        set { recordingsRaw = newValue.map { NSOrderedSet(array: $0) } }
    }

    var statusText: String {
        if let date = endedAt {
            return String.localizedStringWithFormat(
                String(localized: "Concluded %@", bundle: .core, comment: "concluded datetime"),
                date.dateTimeString
            )
        }
        if startedAt != nil {
            return String(localized: "In Progress", bundle: .core)
        }
        return String(localized: "Not Started", bundle: .core)
    }

    var statusLongText: NSAttributedString {
        if let date = startedAt, endedAt == nil {
            let status = NSMutableAttributedString()
            status.append(NSAttributedString(string: statusText, attributes: [.foregroundColor: statusColor]))
            status.append(NSAttributedString(string: " | "))
            status.append(NSAttributedString(string: String.localizedStringWithFormat(
                String(localized: "Started %@", bundle: .core, comment: "started datetime"),
                date.dateTimeString
            )))
            return status
        }
        return NSAttributedString(string: statusText, attributes: [.foregroundColor: statusColor])
    }

    var statusColor: UIColor {
        if startedAt != nil, endedAt == nil {
            return .textSuccess
        }
        return .textDark
    }

    @discardableResult
    static func save(_ item: APIConference, in client: NSManagedObjectContext, context: Context) -> Conference {
        let model: Conference = client.first(where: #keyPath(Conference.id), equals: item.id.value) ?? client.insert()
        model.context = context
        model.conferenceKey = item.conference_key
        model.conferenceType = item.conference_type
        model.details = item.description ?? ""
        model.duration = item.duration
        model.endedAt = item.ended_at
        model.id = item.id.value
        model.isConcluded = item.ended_at != nil
        model.isLive = (
            (item.started_at.map { $0 > Clock.now.addDays(-1) && $0 < Clock.now } ?? false) &&
            (item.ended_at ?? .distantFuture) > Clock.now
        )
        model.isLongRunning = item.long_running
        model.joinURL = item.join_url?.rawValue
        model.order = (
            item.ended_at?.isoString() ?? // concluded by end date desc
            item.started_at?.isoString() ?? // live by start desc
            "0000-\(item.id)" // not started by id desc
        )
        model.recordings = item.recordings?.map {
            ConferenceRecording.save($0, in: client)
        }
        model.startedAt = item.started_at
        model.title = item.title
        model.url = item.url?.rawValue
        return model
    }
}

final class ConferenceRecording: NSManagedObject, WriteableModel {
    typealias JSON = APIConferenceRecording

    @NSManaged var createdAt: Date?
    @NSManaged var duration: Double
    @NSManaged var playbackURL: URL?
    @NSManaged var recordingID: String
    @NSManaged var title: String
    @NSManaged var updatedAt: Date?

    @discardableResult
    static func save(_ item: APIConferenceRecording, in context: NSManagedObjectContext) -> ConferenceRecording {
        let model: ConferenceRecording = context.first(where: #keyPath(ConferenceRecording.recordingID), equals: item.recording_id.value) ?? context.insert()
        model.createdAt = item.created_at.rawValue
        model.duration = item.duration_minutes
        model.playbackURL = item.playback_url?.rawValue ??
                            item.playback_formats.first { $0.type.contains("video") }?.url.rawValue ??
                            item.playback_formats.first { $0.type.contains("presentation") }?.url.rawValue
        model.recordingID = item.recording_id.value
        model.title = item.title
        model.updatedAt = item.updated_at?.rawValue
        return model
    }
}

class GetConferences: APIUseCase {
    typealias Model = Conference

    let context: Context
    var ignored: Set<String> = []

    init(context: Context) {
        self.context = context
    }

    var cacheKey: String? { "\(context.pathComponent)/conferences" }

    var scope: Scope { Scope(
        predicate: NSPredicate(format: "%K == %@",
            #keyPath(Conference.canvasContextID),
            context.canvasContextID
        ),
        order: [
            NSSortDescriptor(key: #keyPath(Conference.isConcluded), ascending: true),
            NSSortDescriptor(key: #keyPath(Conference.order), ascending: false, naturally: true)
        ],
        sectionNameKeyPath: #keyPath(Conference.isConcluded)
    ) }

    var request: GetConferencesRequest {
        GetConferencesRequest(context: context)
    }

    func reset(context: NSManagedObjectContext) {
        ignored = Set((context.fetch(NSPredicate(key: #keyPath(Conference.isIgnored), equals: true)) as [Conference]).map { $0.id })
        context.delete(context.fetch(scope: scope) as [Model])
    }

    func write(response: GetConferencesRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.conferences.forEach {
            let model = Conference.save($0, in: client, context: context)
            model.isIgnored = ignored.contains(model.id)
        }
    }
}

class GetLiveConferences: CollectionUseCase {
    typealias Model = Conference

    var ignored: Set<String> = []

    var cacheKey: String? { nil } // always refresh

    var request: GetLiveConferencesRequest { GetLiveConferencesRequest() }

    var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Conference.isLive), equals: true),
            NSPredicate(key: #keyPath(Conference.isIgnored), equals: false)
        ]),
        orderBy: #keyPath(Conference.order), ascending: false, naturally: true
    ) }

    func reset(context: NSManagedObjectContext) {
        ignored = Set((context.fetch(NSPredicate(key: #keyPath(Conference.isIgnored), equals: true)) as [Conference]).map { $0.id })
        context.delete(context.fetch(scope: scope) as [Model])
    }

    func write(response: GetConferencesRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.conferences.forEach { item in
            if let type = item.context_type.flatMap({ ContextType(rawValue: $0.lowercased()) }), let id = item.context_id?.value {
                let model = Conference.save(item, in: client, context: Context(type, id: id))
                model.isIgnored = ignored.contains(model.id)
            }
        }
    }
}
