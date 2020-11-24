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

import Foundation

// https://canvas.instructure.com/doc/api/conferences.html#Conference
public struct APIConference: Codable {
    let conference_key: String?
    let conference_type: String
    let context_id: ID?
    let context_type: String?
    let description: String?
    let duration: Double? // minutes
    let ended_at: Date?
    let has_advanced_settings: Bool
    let id: ID
    let join_url: APIURL?
    let long_running: Bool
    let recordings: [APIConferenceRecording]?
    let started_at: Date?
    let title: String
    let url: APIURL?
    let users: [ID]?
    // let user_settings: [String: Codable]
}

// https://canvas.instructure.com/doc/api/conferences.html#ConferenceRecording
public struct APIConferenceRecording: Codable {
    let created_at: APIDate
    let duration_minutes: Double
    let playback_formats: [APIConferencePlaybackFormat]
    let playback_url: APIURL?
    let recording_id: ID
    let title: String
    let updated_at: APIDate?
}

public struct APIConferencePlaybackFormat: Codable {
    let length: String?
    let type: String
    let url: APIURL
}

#if DEBUG
extension APIConference {
    public static func make(
        conference_key: String? = "a",
        conference_type: String = "BigBlueButton",
        context_id: ID? = nil,
        context_type: String? = nil,
        description: String? = "test description",
        duration: Double? = 60,
        ended_at: Date? = nil,
        has_advanced_settings: Bool = false,
        id: String = "1",
        join_url: URL? = nil,
        long_running: Bool = false,
        recordings: [APIConferenceRecording]? = nil,
        started_at: Date? = nil,
        title: String = "test conference",
        url: URL? = nil,
        users: [String]? = nil
    ) -> APIConference {
        return APIConference(
            conference_key: conference_key,
            conference_type: conference_type,
            context_id: context_id,
            context_type: context_type,
            description: description,
            duration: duration,
            ended_at: ended_at,
            has_advanced_settings: has_advanced_settings,
            id: ID(id),
            join_url: APIURL(rawValue: join_url),
            long_running: long_running,
            recordings: recordings,
            started_at: started_at,
            title: title,
            url: APIURL(rawValue: url),
            users: users.flatMap { $0.map({ ID($0) }) }
        )
    }
}

extension APIConferenceRecording {
    public static func make(
        created_at: Date = Clock.now,
        duration_minutes: Double = 60,
        playback_formats: [APIConferencePlaybackFormat] = [.make()],
        playback_url: URL? = URL(string: "data:video/mp4,"),
        recording_id: String = "1",
        title: String = "course1: test conference",
        updated_at: Date? = Clock.now
    ) -> APIConferenceRecording {
        return APIConferenceRecording(
            created_at: APIDate(rawValue: created_at),
            duration_minutes: duration_minutes,
            playback_formats: playback_formats,
            playback_url: APIURL(rawValue: playback_url),
            recording_id: ID(recording_id),
            title: title,
            updated_at: APIDate(rawValue: updated_at)
        )
    }
}

extension APIConferencePlaybackFormat {
    public static func make(
        length: String = "5 minutes",
        type: String = "video/mp4",
        url: URL = URL(string: "data:video/mp4,")!
    ) -> APIConferencePlaybackFormat {
        return APIConferencePlaybackFormat(
            length: length,
            type: type,
            url: APIURL(rawValue: url)
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/conferences.html#method.conferences.index
struct GetConferencesRequest: APIRequestable {
    struct Response: Codable {
        let conferences: [APIConference]
    }

    let path: String
    let query: [APIQueryItem]

    init(context: Context, perPage: Int = 100) {
        path = "\(context.pathComponent)/conferences"
        query = [.perPage(perPage)]
    }
}

// https://canvas.instructure.com/doc/api/conferences.html#method.conferences.for_user
struct GetLiveConferencesRequest: APIRequestable {
    typealias Response = GetConferencesRequest.Response

    var path: String { "conferences?state=live" }
}
