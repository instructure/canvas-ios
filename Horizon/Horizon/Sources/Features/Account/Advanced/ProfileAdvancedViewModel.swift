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
        String(localized: "Hawaii (-10:00)", bundle: .horizon): "Pacific/Honolulu",
        String(localized: "Alaska (-09:00/-08:00)", bundle: .horizon): "America/Juneau",
        String(localized: "Pacific Time (US & Canada) (-08:00/-07:00)", bundle: .horizon): "America/Los_Angeles",
        String(localized: "Arizona (-07:00)", bundle: .horizon): "America/Phoenix",
        String(localized: "Mountain Time (US & Canada) (-07:00/-06:00)", bundle: .horizon): "America/Denver",
        String(localized: "Central Time (US & Canada) (-06:00/-05:00)", bundle: .horizon): "America/Chicago",
        String(localized: "Eastern Time (US & Canada) (-05:00/-04:00)", bundle: .horizon): "America/New_York",
        String(localized: "Indiana (East) (-05:00/-04:00)", bundle: .horizon): "America/Indiana/Indianapolis",
        "-------------": "",
        String(localized: "International Date Line West (-12:00)", bundle: .horizon): "Etc/GMT+12",
        String(localized: "American Samoa (-11:00)", bundle: .horizon): "Pacific/Pago_Pago",
        String(localized: "Midway Island (-11:00)", bundle: .horizon): "Pacific/Midway",
        String(localized: "Tijuana (-08:00/-07:00)", bundle: .horizon): "America/Tijuana",
        String(localized: "Mazatlan (-07:00)", bundle: .horizon): "America/Mazatlan",
        String(localized: "Central America (-06:00)", bundle: .horizon): "America/Guatemala",
        String(localized: "Chihuahua (-06:00)", bundle: .horizon): "America/Chihuahua",
        String(localized: "Guadalajara (-06:00)", bundle: .horizon): "America/Mexico_City",
        String(localized: "Mexico City (-06:00)", bundle: .horizon): "America/Mexico_City",
        String(localized: "Monterrey (-06:00)", bundle: .horizon): "America/Monterrey",
        String(localized: "Saskatchewan (-06:00)", bundle: .horizon): "America/Regina",
        String(localized: "Bogota (-05:00/-05:00)", bundle: .horizon): "America/Bogota",
        String(localized: "Eirunepe (-05:00/-05:00)", bundle: .horizon): "America/Lima",
        String(localized: "Lima (-05:00/-05:00)", bundle: .horizon): "America/Lima",
        String(localized: "Quito (-05:00/-05:00)", bundle: .horizon): "America/Lima",
        String(localized: "Asuncion (-04:00/-03:00)", bundle: .horizon): "America/Asuncion",
        String(localized: "Atlantic Time (Canada) (-04:00/-03:00)", bundle: .horizon): "America/Halifax",
        String(localized: "Caracas (-04:00/-04:00)", bundle: .horizon): "America/Caracas",
        String(localized: "Cuiaba (-04:00/-04:00)", bundle: .horizon): "America/Cuiaba",
        String(localized: "Georgetown (-04:00/-04:00)", bundle: .horizon): "America/Guyana",
        String(localized: "La Paz (-04:00/-04:00)", bundle: .horizon): "America/La_Paz",
        String(localized: "Manaus (-04:00/-04:00)", bundle: .horizon): "America/Manaus",
        String(localized: "Puerto Rico (-04:00)", bundle: .horizon): "America/Puerto_Rico",
        String(localized: "Santiago (-04:00/-03:00)", bundle: .horizon): "America/Santiago",
        String(localized: "Newfoundland (-03:30/-02:30)", bundle: .horizon): "America/St_Johns",
        String(localized: "Brasilia (-03:00/-03:00)", bundle: .horizon): "America/Sao_Paulo",
        String(localized: "Buenos Aires (-03:00/-03:00)", bundle: .horizon): "America/Argentina/Buenos_Aires",
        String(localized: "Fortaleza (-03:00/-03:00)", bundle: .horizon): "America/Fortaleza",
        String(localized: "Montevideo (-03:00/-03:00)", bundle: .horizon): "America/Montevideo",
        String(localized: "Greenland (-02:00/-01:00)", bundle: .horizon): "America/Godthab",
        String(localized: "Mid-Atlantic (-02:00/-02:00)", bundle: .horizon): "Atlantic/South_Georgia",
        String(localized: "Noronha (-02:00/-02:00)", bundle: .horizon): "America/Noronha",
        String(localized: "Azores (-01:00/+00:00)", bundle: .horizon): "Atlantic/Azores",
        String(localized: "Cape Verde Is. (-01:00/-01:00)", bundle: .horizon): "Atlantic/Cape_Verde",
        String(localized: "Edinburgh (+00:00/+01:00)", bundle: .horizon): "Europe/London",
        String(localized: "Lisbon (+00:00/+01:00)", bundle: .horizon): "Europe/Lisbon",
        String(localized: "London (+00:00/+01:00)", bundle: .horizon): "Europe/London",
        String(localized: "Monrovia (+00:00)", bundle: .horizon): "Africa/Monrovia",
        String(localized: "UTC (+00:00)", bundle: .horizon): "Etc/UTC",
        String(localized: "Amsterdam (+01:00/+02:00)", bundle: .horizon): "Europe/Amsterdam",
        String(localized: "Belgrade (+01:00/+02:00)", bundle: .horizon): "Europe/Belgrade",
        String(localized: "Berlin (+01:00/+02:00)", bundle: .horizon): "Europe/Berlin",
        String(localized: "Bern (+01:00/+02:00)", bundle: .horizon): "Europe/Zurich",
        String(localized: "Bratislava (+01:00/+02:00)", bundle: .horizon): "Europe/Bratislava",
        String(localized: "Brussels (+01:00/+02:00)", bundle: .horizon): "Europe/Brussels",
        String(localized: "Budapest (+01:00/+02:00)", bundle: .horizon): "Europe/Budapest",
        String(localized: "Casablanca (+01:00/+00:00)", bundle: .horizon): "Africa/Casablanca",
        String(localized: "Copenhagen (+01:00/+02:00)", bundle: .horizon): "Europe/Copenhagen",
        String(localized: "Dublin (+01:00/+00:00)", bundle: .horizon): "Europe/Dublin",
        String(localized: "Ljubljana (+01:00/+02:00)", bundle: .horizon): "Europe/Ljubljana",
        String(localized: "Madrid (+01:00/+02:00)", bundle: .horizon): "Europe/Madrid",
        String(localized: "Paris (+01:00/+02:00)", bundle: .horizon): "Europe/Paris",
        String(localized: "Prague (+01:00/+02:00)", bundle: .horizon): "Europe/Prague",
        String(localized: "Rome (+01:00/+02:00)", bundle: .horizon): "Europe/Rome",
        String(localized: "Sarajevo (+01:00/+02:00)", bundle: .horizon): "Europe/Sarajevo",
        String(localized: "Skopje (+01:00/+02:00)", bundle: .horizon): "Europe/Skopje",
        String(localized: "Stockholm (+01:00/+02:00)", bundle: .horizon): "Europe/Stockholm",
        String(localized: "Vienna (+01:00/+02:00)", bundle: .horizon): "Europe/Vienna",
        String(localized: "Warsaw (+01:00/+02:00)", bundle: .horizon): "Europe/Warsaw",
        String(localized: "West Central Africa (+01:00)", bundle: .horizon): "Africa/Algiers",
        String(localized: "Zagreb (+01:00/+02:00)", bundle: .horizon): "Europe/Zagreb",
        String(localized: "Zurich (+01:00/+02:00)", bundle: .horizon): "Europe/Zurich",
        String(localized: "Athens (+02:00/+03:00)", bundle: .horizon): "Europe/Athens",
        String(localized: "Bucharest (+02:00/+03:00)", bundle: .horizon): "Europe/Bucharest",
        String(localized: "Cairo (+02:00/+03:00)", bundle: .horizon): "Africa/Cairo",
        String(localized: "Harare (+02:00)", bundle: .horizon): "Africa/Harare",
        String(localized: "Helsinki (+02:00/+03:00)", bundle: .horizon): "Europe/Helsinki",
        String(localized: "Jerusalem (+02:00/+03:00)", bundle: .horizon): "Asia/Jerusalem",
        String(localized: "Kaliningrad (+02:00)", bundle: .horizon): "Europe/Kaliningrad",
        String(localized: "Kyiv (+02:00/+03:00)", bundle: .horizon): "Europe/Kiev",
        String(localized: "Pretoria (+02:00)", bundle: .horizon): "Africa/Johannesburg",
        String(localized: "Riga (+02:00/+03:00)", bundle: .horizon): "Europe/Riga",
        String(localized: "Sofia (+02:00/+03:00)", bundle: .horizon): "Europe/Sofia",
        String(localized: "Tallinn (+02:00/+03:00)", bundle: .horizon): "Europe/Tallinn",
        String(localized: "Vilnius (+02:00/+03:00)", bundle: .horizon): "Europe/Vilnius",
        String(localized: "Baghdad (+03:00/+03:00)", bundle: .horizon): "Asia/Baghdad",
        String(localized: "Istanbul (+03:00/+03:00)", bundle: .horizon): "Europe/Istanbul",
        String(localized: "Kuwait (+03:00/+03:00)", bundle: .horizon): "Asia/Kuwait",
        String(localized: "Minsk (+03:00/+03:00)", bundle: .horizon): "Europe/Minsk",
        String(localized: "Moscow (+03:00)", bundle: .horizon): "Europe/Moscow",
        String(localized: "Nairobi (+03:00)", bundle: .horizon): "Africa/Nairobi",
        String(localized: "Riyadh (+03:00/+03:00)", bundle: .horizon): "Asia/Riyadh",
        String(localized: "St. Petersburg (+03:00)", bundle: .horizon): "Europe/Moscow",
        String(localized: "Volgograd (+03:00)", bundle: .horizon): "Europe/Volgograd",
        String(localized: "Tehran (+03:30/+03:30)", bundle: .horizon): "Asia/Tehran",
        String(localized: "Abu Dhabi (+04:00/+04:00)", bundle: .horizon): "Asia/Muscat",
        String(localized: "Baku (+04:00/+04:00)", bundle: .horizon): "Asia/Baku",
        String(localized: "Muscat (+04:00/+04:00)", bundle: .horizon): "Asia/Muscat",
        String(localized: "Samara (+04:00/+04:00)", bundle: .horizon): "Europe/Samara",
        String(localized: "Tbilisi (+04:00/+04:00)", bundle: .horizon): "Asia/Tbilisi",
        String(localized: "Yerevan (+04:00/+04:00)", bundle: .horizon): "Asia/Yerevan",
        String(localized: "Kabul (+04:30/+04:30)", bundle: .horizon): "Asia/Kabul",
        String(localized: "Almaty (+05:00/+05:00)", bundle: .horizon): "Asia/Almaty",
        String(localized: "Astana (+05:00/+05:00)", bundle: .horizon): "Asia/Almaty",
        String(localized: "Ekaterinburg (+05:00/+05:00)", bundle: .horizon): "Asia/Yekaterinburg",
        String(localized: "Islamabad (+05:00)", bundle: .horizon): "Asia/Karachi",
        String(localized: "Karachi (+05:00)", bundle: .horizon): "Asia/Karachi",
        String(localized: "Tashkent (+05:00/+05:00)", bundle: .horizon): "Asia/Tashkent",
        String(localized: "Chennai (+05:30)", bundle: .horizon): "Asia/Kolkata",
        String(localized: "Kolkata (+05:30)", bundle: .horizon): "Asia/Kolkata",
        String(localized: "Mumbai (+05:30)", bundle: .horizon): "Asia/Kolkata",
        String(localized: "New Delhi (+05:30)", bundle: .horizon): "Asia/Kolkata",
        String(localized: "Sri Jayawardenepura (+05:30/+05:30)", bundle: .horizon): "Asia/Colombo",
        String(localized: "Kathmandu (+05:45/+05:45)", bundle: .horizon): "Asia/Kathmandu",
        String(localized: "Dhaka (+06:00/+06:00)", bundle: .horizon): "Asia/Dhaka",
        String(localized: "Urumqi (+06:00/+06:00)", bundle: .horizon): "Asia/Urumqi",
        String(localized: "Rangoon (+06:30/+06:30)", bundle: .horizon): "Asia/Rangoon",
        String(localized: "Bangkok (+07:00/+07:00)", bundle: .horizon): "Asia/Bangkok",
        String(localized: "Hanoi (+07:00/+07:00)", bundle: .horizon): "Asia/Bangkok",
        String(localized: "Jakarta (+07:00)", bundle: .horizon): "Asia/Jakarta",
        String(localized: "Krasnoyarsk (+07:00/+07:00)", bundle: .horizon): "Asia/Krasnoyarsk",
        String(localized: "Novosibirsk (+07:00/+07:00)", bundle: .horizon): "Asia/Novosibirsk",
        String(localized: "Beijing (+08:00)", bundle: .horizon): "Asia/Shanghai",
        String(localized: "Chongqing (+08:00)", bundle: .horizon): "Asia/Chongqing",
        String(localized: "Hong Kong (+08:00)", bundle: .horizon): "Asia/Hong_Kong",
        String(localized: "Irkutsk (+08:00/+08:00)", bundle: .horizon): "Asia/Irkutsk",
        String(localized: "Kuala Lumpur (+08:00/+08:00)", bundle: .horizon): "Asia/Kuala_Lumpur",
        String(localized: "Perth (+08:00)", bundle: .horizon): "Australia/Perth",
        String(localized: "Philippines (+08:00)", bundle: .horizon): "Asia/Manila",
        String(localized: "Singapore (+08:00/+08:00)", bundle: .horizon): "Asia/Singapore",
        String(localized: "Taipei (+08:00)", bundle: .horizon): "Asia/Taipei",
        String(localized: "Ulaanbaatar (+08:00/+08:00)", bundle: .horizon): "Asia/Ulaanbaatar",
        String(localized: "Osaka (+09:00)", bundle: .horizon): "Asia/Tokyo",
        String(localized: "Sapporo (+09:00)", bundle: .horizon): "Asia/Tokyo",
        String(localized: "Seoul (+09:00)", bundle: .horizon): "Asia/Seoul",
        String(localized: "Tokyo (+09:00)", bundle: .horizon): "Asia/Tokyo",
        String(localized: "Yakutsk (+09:00/+09:00)", bundle: .horizon): "Asia/Yakutsk",
        String(localized: "Adelaide (+09:30/+10:30)", bundle: .horizon): "Australia/Adelaide",
        String(localized: "Darwin (+09:30)", bundle: .horizon): "Australia/Darwin",
        String(localized: "Brisbane (+10:00)", bundle: .horizon): "Australia/Brisbane",
        String(localized: "Canberra (+10:00/+11:00)", bundle: .horizon): "Australia/Canberra",
        String(localized: "Guam (+10:00)", bundle: .horizon): "Pacific/Guam",
        String(localized: "Hobart (+10:00/+11:00)", bundle: .horizon): "Australia/Hobart",
        String(localized: "Melbourne (+10:00/+11:00)", bundle: .horizon): "Australia/Melbourne",
        String(localized: "Port Moresby (+10:00/+10:00)", bundle: .horizon): "Pacific/Port_Moresby",
        String(localized: "Sydney (+10:00/+11:00)", bundle: .horizon): "Australia/Sydney",
        String(localized: "Vladivostok (+10:00/+10:00)", bundle: .horizon): "Asia/Vladivostok",
        String(localized: "Magadan (+11:00/+11:00)", bundle: .horizon): "Asia/Magadan",
        String(localized: "New Caledonia (+11:00/+11:00)", bundle: .horizon): "Pacific/Noumea",
        String(localized: "Norfolk Island (+11:00/+12:00)", bundle: .horizon): "Pacific/Norfolk",
        String(localized: "Solomon Is. (+11:00/+11:00)", bundle: .horizon): "Pacific/Guadalcanal",
        String(localized: "Srednekolymsk (+11:00/+11:00)", bundle: .horizon): "Asia/Srednekolymsk",
        String(localized: "Auckland (+12:00/+13:00)", bundle: .horizon): "Pacific/Auckland",
        String(localized: "Fiji (+12:00/+12:00)", bundle: .horizon): "Pacific/Fiji",
        String(localized: "Kamchatka (+12:00/+12:00)", bundle: .horizon): "Asia/Kamchatka",
        String(localized: "Marshall Is. (+12:00/+12:00)", bundle: .horizon): "Pacific/Majuro",
        String(localized: "Wellington (+12:00/+13:00)", bundle: .horizon): "Pacific/Auckland",
        String(localized: "Chatham Is. (+12:45/+13:45)", bundle: .horizon): "Pacific/Chatham",
        String(localized: "Nuku'alofa (+13:00/+13:00)", bundle: .horizon): "Pacific/Tongatapu",
        String(localized: "Samoa (+13:00/+13:00)", bundle: .horizon): "Pacific/Apia",
        String(localized: "Tokelau Is. (+13:00/+13:00)", bundle: .horizon): "Pacific/Fakaofo"
    ]

}
