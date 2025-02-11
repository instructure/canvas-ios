//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Observation

@Observable
class ProfileAdvancedViewModel {

    // MARK: - Outputs

    var isLoading: Bool = false
    var isSaveDisabled: Bool = false
    var isSelectDisabled: Bool {
        isLoading
    }
    var timeZone: String = "" {
        didSet {
            onTimeZoneSelected()
        }
    }
    var timeZones: [String] {
        timeZoneMap.map { $0.key }
    }

    // MARK: - Private Properties

    private var timeZoneValue: String {
        timeZoneMap.first(where: { $0.key == timeZone })?.value ?? ""
    }

    private var originalTimeZone = "" {
        didSet {
            timeZone = originalTimeZone
        }
    }

    // MARK: - Dependencies

    private let updateUserProfileInteractor: UpdateUserProfileInteractor
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        getUserInteractor: GetUserInteractor = GetUserInteractorLive(),
        updateUserProfileInteractor: UpdateUserProfileInteractor = UpdateUserProfileInteractorLive()
    ) {
        self.updateUserProfileInteractor = updateUserProfileInteractor

        self.isLoading = true
        getUserInteractor
            .getUser()
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] user in
                    self?.originalTimeZone = user.defaultTimeZone ?? ""
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func save() {
        if timeZoneValue.isEmpty {
            return
        }
        isLoading = true
        updateUserProfileInteractor.set(timeZone: timeZoneValue)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] userProfile in
                    self?.originalTimeZone = userProfile?.defaultTimeZone ?? ""
                    self?.updateSaveDisabled()
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func onTimeZoneSelected() {
        updateSaveDisabled()
    }

    private func updateSaveDisabled() {
        isSaveDisabled = timeZone == originalTimeZone || timeZone.isEmpty || timeZoneValue.isEmpty
    }

    private let timeZoneMap: KeyValuePairs<String, String> = [
        "Hawaii (-10:00)": "Pacific/Honolulu",
        "Alaska (-09:00/-08:00)": "America/Juneau",
        "Pacific Time (US & Canada) (-08:00/-07:00)": "America/Los_Angeles",
        "Arizona (-07:00)": "America/Phoenix",
        "Mountain Time (US & Canada) (-07:00/-06:00)": "America/Denver",
        "Central Time (US & Canada) (-06:00/-05:00)": "America/Chicago",
        "Eastern Time (US & Canada) (-05:00/-04:00)": "America/New_York",
        "Indiana (East) (-05:00/-04:00)": "America/Indiana/Indianapolis",
        "-------------": "",
        "International Date Line West (-12:00)": "Etc/GMT+12",
        "American Samoa (-11:00)": "Pacific/Pago_Pago",
        "Midway Island (-11:00)": "Pacific/Midway",
        "Tijuana (-08:00/-07:00)": "America/Tijuana",
        "Mazatlan (-07:00)": "America/Mazatlan",
        "Central America (-06:00)": "America/Guatemala",
        "Chihuahua (-06:00)": "America/Chihuahua",
        "Guadalajara (-06:00)": "America/Mexico_City",
        "Mexico City (-06:00)": "America/Mexico_City",
        "Monterrey (-06:00)": "America/Monterrey",
        "Saskatchewan (-06:00)": "America/Regina",
        "Bogota (-05:00/-05:00)": "America/Bogota",
        "Eirunepe (-05:00/-05:00)": "America/Lima",
        "Lima (-05:00/-05:00)": "America/Lima",
        "Quito (-05:00/-05:00)": "America/Lima",
        "Asuncion (-04:00/-03:00)": "America/Asuncion",
        "Atlantic Time (Canada) (-04:00/-03:00)": "America/Halifax",
        "Caracas (-04:00/-04:00)": "America/Caracas",
        "Cuiaba (-04:00/-04:00)": "America/Cuiaba",
        "Georgetown (-04:00/-04:00)": "America/Guyana",
        "La Paz (-04:00/-04:00)": "America/La_Paz",
        "Manaus (-04:00/-04:00)": "America/Manaus",
        "Puerto Rico (-04:00)": "America/Puerto_Rico",
        "Santiago (-04:00/-03:00)": "America/Santiago",
        "Newfoundland (-03:30/-02:30)": "America/St_Johns",
        "Brasilia (-03:00/-03:00)": "America/Sao_Paulo",
        "Buenos Aires (-03:00/-03:00)": "America/Argentina/Buenos_Aires",
        "Fortaleza (-03:00/-03:00)": "America/Fortaleza",
        "Montevideo (-03:00/-03:00)": "America/Montevideo",
        "Greenland (-02:00/-01:00)": "America/Godthab",
        "Mid-Atlantic (-02:00/-02:00)": "Atlantic/South_Georgia",
        "Noronha (-02:00/-02:00)": "America/Noronha",
        "Azores (-01:00/+00:00)": "Atlantic/Azores",
        "Cape Verde Is. (-01:00/-01:00)": "Atlantic/Cape_Verde",
        "Edinburgh (+00:00/+01:00)": "Europe/London",
        "Lisbon (+00:00/+01:00)": "Europe/Lisbon",
        "London (+00:00/+01:00)": "Europe/London",
        "Monrovia (+00:00)": "Africa/Monrovia",
        "UTC (+00:00)": "Etc/UTC",
        "Amsterdam (+01:00/+02:00)": "Europe/Amsterdam",
        "Belgrade (+01:00/+02:00)": "Europe/Belgrade",
        "Berlin (+01:00/+02:00)": "Europe/Berlin",
        "Bern (+01:00/+02:00)": "Europe/Zurich",
        "Bratislava (+01:00/+02:00)": "Europe/Bratislava",
        "Brussels (+01:00/+02:00)": "Europe/Brussels",
        "Budapest (+01:00/+02:00)": "Europe/Budapest",
        "Casablanca (+01:00/+00:00)": "Africa/Casablanca",
        "Copenhagen (+01:00/+02:00)": "Europe/Copenhagen",
        "Dublin (+01:00/+00:00)": "Europe/Dublin",
        "Ljubljana (+01:00/+02:00)": "Europe/Ljubljana",
        "Madrid (+01:00/+02:00)": "Europe/Madrid",
        "Paris (+01:00/+02:00)": "Europe/Paris",
        "Prague (+01:00/+02:00)": "Europe/Prague",
        "Rome (+01:00/+02:00)": "Europe/Rome",
        "Sarajevo (+01:00/+02:00)": "Europe/Sarajevo",
        "Skopje (+01:00/+02:00)": "Europe/Skopje",
        "Stockholm (+01:00/+02:00)": "Europe/Stockholm",
        "Vienna (+01:00/+02:00)": "Europe/Vienna",
        "Warsaw (+01:00/+02:00)": "Europe/Warsaw",
        "West Central Africa (+01:00)": "Africa/Algiers",
        "Zagreb (+01:00/+02:00)": "Europe/Zagreb",
        "Zurich (+01:00/+02:00)": "Europe/Zurich",
        "Athens (+02:00/+03:00)": "Europe/Athens",
        "Bucharest (+02:00/+03:00)": "Europe/Bucharest",
        "Cairo (+02:00/+03:00)": "Africa/Cairo",
        "Harare (+02:00)": "Africa/Harare",
        "Helsinki (+02:00/+03:00)": "Europe/Helsinki",
        "Jerusalem (+02:00/+03:00)": "Asia/Jerusalem",
        "Kaliningrad (+02:00)": "Europe/Kaliningrad",
        "Kyiv (+02:00/+03:00)": "Europe/Kiev",
        "Pretoria (+02:00)": "Africa/Johannesburg",
        "Riga (+02:00/+03:00)": "Europe/Riga",
        "Sofia (+02:00/+03:00)": "Europe/Sofia",
        "Tallinn (+02:00/+03:00)": "Europe/Tallinn",
        "Vilnius (+02:00/+03:00)": "Europe/Vilnius",
        "Baghdad (+03:00/+03:00)": "Asia/Baghdad",
        "Istanbul (+03:00/+03:00)": "Europe/Istanbul",
        "Kuwait (+03:00/+03:00)": "Asia/Kuwait",
        "Minsk (+03:00/+03:00)": "Europe/Minsk",
        "Moscow (+03:00)": "Europe/Moscow",
        "Nairobi (+03:00)": "Africa/Nairobi",
        "Riyadh (+03:00/+03:00)": "Asia/Riyadh",
        "St. Petersburg (+03:00)": "Europe/Moscow",
        "Volgograd (+03:00)": "Europe/Volgograd",
        "Tehran (+03:30/+03:30)": "Asia/Tehran",
        "Abu Dhabi (+04:00/+04:00)": "Asia/Muscat",
        "Baku (+04:00/+04:00)": "Asia/Baku",
        "Muscat (+04:00/+04:00)": "Asia/Muscat",
        "Samara (+04:00/+04:00)": "Europe/Samara",
        "Tbilisi (+04:00/+04:00)": "Asia/Tbilisi",
        "Yerevan (+04:00/+04:00)": "Asia/Yerevan",
        "Kabul (+04:30/+04:30)": "Asia/Kabul",
        "Almaty (+05:00/+05:00)": "Asia/Almaty",
        "Astana (+05:00/+05:00)": "Asia/Almaty",
        "Ekaterinburg (+05:00/+05:00)": "Asia/Yekaterinburg",
        "Islamabad (+05:00)": "Asia/Karachi",
        "Karachi (+05:00)": "Asia/Karachi",
        "Tashkent (+05:00/+05:00)": "Asia/Tashkent",
        "Chennai (+05:30)": "Asia/Kolkata",
        "Kolkata (+05:30)": "Asia/Kolkata",
        "Mumbai (+05:30)": "Asia/Kolkata",
        "New Delhi (+05:30)": "Asia/Kolkata",
        "Sri Jayawardenepura (+05:30/+05:30)": "Asia/Colombo",
        "Kathmandu (+05:45/+05:45)": "Asia/Kathmandu",
        "Dhaka (+06:00/+06:00)": "Asia/Dhaka",
        "Urumqi (+06:00/+06:00)": "Asia/Urumqi",
        "Rangoon (+06:30/+06:30)": "Asia/Rangoon",
        "Bangkok (+07:00/+07:00)": "Asia/Bangkok",
        "Hanoi (+07:00/+07:00)": "Asia/Bangkok",
        "Jakarta (+07:00)": "Asia/Jakarta",
        "Krasnoyarsk (+07:00/+07:00)": "Asia/Krasnoyarsk",
        "Novosibirsk (+07:00/+07:00)": "Asia/Novosibirsk",
        "Beijing (+08:00)": "Asia/Shanghai",
        "Chongqing (+08:00)": "Asia/Chongqing",
        "Hong Kong (+08:00)": "Asia/Hong_Kong",
        "Irkutsk (+08:00/+08:00)": "Asia/Irkutsk",
        "Kuala Lumpur (+08:00/+08:00)": "Asia/Kuala_Lumpur",
        "Perth (+08:00)": "Australia/Perth",
        "Philippines (+08:00)": "Asia/Manila",
        "Singapore (+08:00/+08:00)": "Asia/Singapore",
        "Taipei (+08:00)": "Asia/Taipei",
        "Ulaanbaatar (+08:00/+08:00)": "Asia/Ulaanbaatar",
        "Osaka (+09:00)": "Asia/Tokyo",
        "Sapporo (+09:00)": "Asia/Tokyo",
        "Seoul (+09:00)": "Asia/Seoul",
        "Tokyo (+09:00)": "Asia/Tokyo",
        "Yakutsk (+09:00/+09:00)": "Asia/Yakutsk",
        "Adelaide (+09:30/+10:30)": "Australia/Adelaide",
        "Darwin (+09:30)": "Australia/Darwin",
        "Brisbane (+10:00)": "Australia/Brisbane",
        "Canberra (+10:00/+11:00)": "Australia/Canberra",
        "Guam (+10:00)": "Pacific/Guam",
        "Hobart (+10:00/+11:00)": "Australia/Hobart",
        "Melbourne (+10:00/+11:00)": "Australia/Melbourne",
        "Port Moresby (+10:00/+10:00)": "Pacific/Port_Moresby",
        "Sydney (+10:00/+11:00)": "Australia/Sydney",
        "Vladivostok (+10:00/+10:00)": "Asia/Vladivostok",
        "Magadan (+11:00/+11:00)": "Asia/Magadan",
        "New Caledonia (+11:00/+11:00)": "Pacific/Noumea",
        "Norfolk Island (+11:00/+12:00)": "Pacific/Norfolk",
        "Solomon Is. (+11:00/+11:00)": "Pacific/Guadalcanal",
        "Srednekolymsk (+11:00/+11:00)": "Asia/Srednekolymsk",
        "Auckland (+12:00/+13:00)": "Pacific/Auckland",
        "Fiji (+12:00/+12:00)": "Pacific/Fiji",
        "Kamchatka (+12:00/+12:00)": "Asia/Kamchatka",
        "Marshall Is. (+12:00/+12:00)": "Pacific/Majuro",
        "Wellington (+12:00/+13:00)": "Pacific/Auckland",
        "Chatham Is. (+12:45/+13:45)": "Pacific/Chatham",
        "Nuku'alofa (+13:00/+13:00)": "Pacific/Tongatapu",
        "Samoa (+13:00/+13:00)": "Pacific/Apia",
        "Tokelau Is. (+13:00/+13:00)": "Pacific/Fakaofo"
    ]

}
