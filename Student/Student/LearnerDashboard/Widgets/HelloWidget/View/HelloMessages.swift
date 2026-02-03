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

import Foundation

extension HelloWidgetViewModel {
    static let generic: [String] = [
        .init(localized: "You've got this.", bundle: .student),
        .init(localized: "Keep going — you're stronger than you feel right now.", bundle: .student),
        .init(localized: "One step at a time is still progress.", bundle: .student),
        .init(localized: "Don't give up — future you will thank you.", bundle: .student),
        .init(localized: "You're capable of more than you think.", bundle: .student),
        .init(localized: "Even on tough days, you're moving forward.", bundle: .student),
        .init(localized: "Trust yourself — you've done hard things before.", bundle: .student),
        .init(localized: "Progress, not perfection. You're doing great.", bundle: .student),
        .init(localized: "Hang in there — you're not alone in this.", bundle: .student),
        .init(localized: "You're learning, growing, and doing better than you realize.", bundle: .student),
        .init(localized: "It's okay to stumble — you're still on the right path.", bundle: .student),
        .init(localized: "Keep pushing — you're closer than you think.", bundle: .student),
        .init(localized: "Small wins count too.", bundle: .student),
        .init(localized: "It's okay to pause. Breaks are part of learning.", bundle: .student),
        .init(localized: "Trying is already a win.", bundle: .student),
        .init(localized: "Progress > perfection.", bundle: .student),
        .init(localized: "Showing up matters more than you know.", bundle: .student),
        .init(localized: "You're building skills, even on slow days.", bundle: .student),
        .init(localized: "Don't forget to breathe — you're doing fine.", bundle: .student),
        .init(localized: "Your pace is the right pace.", bundle: .student),
        .init(localized: "Not everything needs to be figured out today.", bundle: .student),
        .init(localized: "You belong here.", bundle: .student),
        .init(localized: "Every effort you make adds up.", bundle: .student),
        .init(localized: "It's okay to start again — as many times as you need.", bundle: .student),
        .init(localized: "What feels hard now will feel easier later.", bundle: .student),
        .init(localized: "Keep showing up — that's what counts.", bundle: .student),
        .init(localized: "Small steps move big mountains.", bundle: .student),
        .init(localized: "Rest is part of progress too.", bundle: .student),
        .init(localized: "You're doing better than you realize.", bundle: .student),
        .init(localized: "Even slow progress is still progress.", bundle: .student),
        .init(localized: "The future isn't built in a day — but you're on the way.", bundle: .student),
        .init(localized: "One assignment, one moment, one step at a time.", bundle: .student),
        .init(localized: "You don't have to be perfect to make an impact.", bundle: .student),
        .init(localized: "Learning is messy — and that's normal.", bundle: .student),
        .init(localized: "Every try is growth, even if it doesn't feel like it.", bundle: .student),
        .init(localized: "You've done hard things before — you can do this too.", bundle: .student),
        .init(localized: "Your effort matters, even if no one sees it.", bundle: .student),
        .init(localized: "It's okay to take things slow.", bundle: .student),
        .init(localized: "You're moving forward, even on quiet days.", bundle: .student),
        .init(localized: "The path doesn't need to be clear yet — keep walking.", bundle: .student),
        .init(localized: "Your effort today is an investment in tomorrow.", bundle: .student),
        .init(localized: "Big goals are built from small steps.", bundle: .student),
        .init(localized: "Keep going — future you will thank you.", bundle: .student),
        .init(localized: "Even messy progress is still progress.", bundle: .student),
        .init(localized: "You're not behind — you're on your path.", bundle: .student),
        .init(localized: "It's okay to learn as you go.", bundle: .student),
        .init(localized: "You're growing in ways you might not see yet.", bundle: .student)
    ]

    static let morning: [String] = [
        .init(localized: "Morning! You've got this — one class, one step at a time.", bundle: .student),
        .init(localized: "Not feeling ready? That's normal. Just start where you are.", bundle: .student),
        .init(localized: "Coffee helps, but kindness to yourself works better.", bundle: .student),
        .init(localized: "Tech acting up? Happens to all of us — don't stress.", bundle: .student),
        .init(localized: "Today doesn't need to be perfect, just possible.", bundle: .student),
        .init(localized: "Good morning — today is a new chance to learn and grow.", bundle: .student),
        .init(localized: "Even small steps this morning move you closer to your goals.", bundle: .student),
        .init(localized: "Take a breath — you don't need to have everything figured out yet.", bundle: .student),
        .init(localized: "Technology can be tricky, but you're not alone in learning it.", bundle: .student)
    ]

    static let afternoon: [String] = [
        .init(localized: "Halfway there — you've already done more than you think.", bundle: .student),
        .init(localized: "Feeling stuck? Everyone hits walls, just don't stop climbing.", bundle: .student),
        .init(localized: "Jobs, grades, the future… no one has it all figured out yet.", bundle: .student),
        .init(localized: "Brain tired? Quick break = better focus later.", bundle: .student),
        .init(localized: "Ask for help. Seriously, no one's doing this solo.", bundle: .student),
        .init(localized: "You've already made it this far today — that's something to be proud of.", bundle: .student),
        .init(localized: "Need a pause? Recharging is part of learning too.", bundle: .student),
        .init(localized: "It's okay if the path feels uncertain — skills build step by step.", bundle: .student),
        .init(localized: "Reach out if you're stuck — support is always closer than it feels.", bundle: .student)
    ]

    static let evening: [String] = [
        .init(localized: "Made it through the day — that's a win in itself.", bundle: .student),
        .init(localized: "Missing people? Shoot someone a quick \"hey\" — it helps.", bundle: .student),
        .init(localized: "Even if today felt messy, you showed up. That matters.", bundle: .student),
        .init(localized: "Remember: no grade measures your worth.", bundle: .student),
        .init(localized: "Relax, laugh, or scroll guilt-free — you earned it.", bundle: .student),
        .init(localized: "Well done getting through the day — progress counts, even when it's quiet.", bundle: .student),
        .init(localized: "Missing friends or mentors? Connection can come in small moments too.", bundle: .student),
        .init(localized: "Evenings are for reflection — notice what you've learned today, not just what's left to do.", bundle: .student),
        .init(localized: "Your effort matters more than perfection.", bundle: .student)
    ]

    static let night: [String] = [
        .init(localized: "Still grinding? Respect — but don't forget sleep exists.", bundle: .student),
        .init(localized: "Tomorrow you'll thank yourself for resting tonight.", bundle: .student),
        .init(localized: "Anxiety gets louder at night — don't believe all its noise.", bundle: .student),
        .init(localized: "You're not behind, you're just on your path.", bundle: .student),
        .init(localized: "Close the laptop — your brain needs dreams too.", bundle: .student),
        .init(localized: "It's okay to rest — tomorrow is waiting with new opportunities.", bundle: .student),
        .init(localized: "Learning is a marathon, not a sprint. Be kind to yourself tonight.", bundle: .student),
        .init(localized: "If worries feel heavy, remember you don't have to carry them alone.", bundle: .student),
        .init(localized: "End the day knowing that trying is already an achievement.", bundle: .student)
    ]
}
