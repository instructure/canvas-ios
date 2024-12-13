//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SwiftUI

public extension HorizonUI.Colors {
    struct Primitives: Sendable, ColorCollection {

        // MARK: - Blue

        public let blue12 = Color(hexString: "#E0EBF5")
        public let blue45 = Color(hexString: "#2B7ABC")
        public let blue57 = Color(hexString: "#0E68B3")
        public let blue70 = Color(hexString: "#0A5A9E")
        public let blue82 = Color(hexString: "#09508C")
        public let blueGradient = [Color(hexString: "#09508C"), Color(hexString: "#0A5A9E")]

        // MARK: - Green

        public let green12 = Color(hexString: "#DCEEE4")
        public let green45 = Color(hexString: "#03893D")
        public let green57 = Color(hexString: "#027634")
        public let green70 = Color(hexString: "#02672D")
        public let green82 = Color(hexString: "#015B28")

        // MARK: - Orange

        public let orange12 =  Color(hexString: "#FCE5D9")
        public let orange30 =  Color(hexString: "#F06E26")
        public let orange45 =  Color(hexString: "#CF4A00")
        public let orange57 =  Color(hexString: "#B34000")
        public let orange70 =  Color(hexString: "#9C3800")
        public let orange82 =  Color(hexString: "#8B3200")

        // MARK: - Red

        public let red12 =  Color(hexString: "#FCE4E5")
        public let red45 =  Color(hexString: "#E62429")
        public let red57 =  Color(hexString: "#C71F23")
        public let red70 =  Color(hexString: "#AE1B1F")
        public let red82 =  Color(hexString: "#9B181C")

        // MARK: - White

        public let white10 =  Color(hexString: "#FFFFFF")

        // MARK: - Grey

        public let grey11 = Color(hexString: "#F2F4F4")
        public let grey12 = Color(hexString: "#E8EAEC")
        public let grey14 = Color(hexString: "#D7DADE")
        public let grey24 = Color(hexString: "#9EA6AD")
        public let grey45 = Color(hexString: "#6A7883")
        public let grey57 = Color(hexString: "#586874")
        public let grey70 = Color(hexString: "#4A5B68")
        public let grey82 = Color(hexString: "#3F515E")
        public let grey100 = Color(hexString: "#334451")
        public let grey125 = Color(hexString: "#273540")

        // MARK: - Black

        public let black174 = Color(hexString: "#0A1B2A")

        // MARK: - Beige

        public let beige10 = Color(hexString: "#FFFDFA")
        public let beige11 = Color(hexString: "#FBF5ED")
        public let beige12 = Color(hexString: "#FDEACC")
        public let beige15 = Color(hexString: "#E3D0B2")
        public let beige19 = Color(hexString: "#CAB79A")
        public let beige26 = Color(hexString: "#B09F83")
        public let beige35 = Color(hexString: "#97876D")
        public let beige49 = Color(hexString: "#7D6F58")
        public let beige69 = Color(hexString: "#645844")
        public let beige100 = Color(hexString: "#4A4131")
        public let beige147 = Color(hexString: "#2F271B")
        public let beigeGradient = [Color(hexString: "#FFFDFA"), Color(hexString: "#FBF5ED")]

        // MARK: - Additional Primitives
        // MARK: - Rose

        public let rose30 = Color(hexString: "#FB5D5D")
        public let rose35 = Color(hexString: "#FA3F3F")
        public let rose40 = Color(hexString: "#FA1A1A")
        public let rose45 = Color(hexString: "#ED0000")
        public let rose50 = Color(hexString: "#E00000")
        public let rose57 = Color(hexString: "#CE0000")
        public let rose70 = Color(hexString: "#B50000")
        public let rose90 = Color(hexString: "#970000")
        public let rose110 = Color(hexString: "#7F0000")

        // MARK: - Copper

        public let copper30 = Color(hexString: "#EE6D15")
        public let copper35 = Color(hexString: "#DB6414")
        public let copper40 = Color(hexString: "#CD5E12")
        public let copper45 = Color(hexString: "#BF5811")
        public let copper50 = Color(hexString: "#B45310")
        public let copper57 = Color(hexString: "#A54C0F")
        public let copper70 = Color(hexString: "#90420D")
        public let copper90 = Color(hexString: "#77360B")
        public let copper110 = Color(hexString: "#622D09")

        // MARK: - Honey

        public let honey30 = Color(hexString: "#C08A00")
        public let honey35 = Color(hexString: "#B07E00")
        public let honey40 = Color(hexString: "#A57600")
        public let honey45 = Color(hexString: "#996E00")
        public let honey50 = Color(hexString: "#916800")
        public let honey57 = Color(hexString: "#856000")
        public let honey70 = Color(hexString: "#745300")
        public let honey90 = Color(hexString: "#5F4400")
        public let honey110 = Color(hexString: "#4E3800")

        // MARK: - Forest

        public let forest30 = Color(hexString: "#55A459")
        public let forest35 = Color(hexString: "#409945")
        public let forest40 = Color(hexString: "#319135")
        public let forest45 = Color(hexString: "#27872B")
        public let forest50 = Color(hexString: "#248029")
        public let forest57 = Color(hexString: "#217526")
        public let forest70 = Color(hexString: "#1D6621")
        public let forest90 = Color(hexString: "#18541B")
        public let forest110 = Color(hexString: "#144516")

        // MARK: - Aurora

        public let aurora30 = Color(hexString: "#38A585")
        public let aurora35 = Color(hexString: "#1E9975")
        public let aurora40 = Color(hexString: "#0B9069")
        public let aurora45 = Color(hexString: "#048660")
        public let aurora50 = Color(hexString: "#047F5B")
        public let aurora57 = Color(hexString: "#037453")
        public let aurora70 = Color(hexString: "#036549")
        public let aurora90 = Color(hexString: "#02533C")
        public let aurora110 = Color(hexString: "#024531")

        // MARK: - Sea

        public let sea30 = Color(hexString: "#37A1AA")
        public let sea35 = Color(hexString: "#1E95A0")
        public let sea40 = Color(hexString: "#0A8C97")
        public let sea45 = Color(hexString: "#00828E")
        public let sea50 = Color(hexString: "#007B86")
        public let sea57 = Color(hexString: "#00717B")
        public let sea70 = Color(hexString: "#00626B")
        public let sea90 = Color(hexString: "#005158")
        public let sea110 = Color(hexString: "#004349")

        // MARK: - Sky
        public let sky30 = Color(hexString: "#4E9CC0")
        public let sky35 = Color(hexString: "#3890B8")
        public let sky40 = Color(hexString: "#2887B2")
        public let sky45 = Color(hexString: "#197EAB")
        public let sky50 = Color(hexString: "#1777A2")
        public let sky57 = Color(hexString: "#156D94")
        public let sky70 = Color(hexString: "#135F81")
        public let sky90 = Color(hexString: "#0F4E6A")
        public let sky110 = Color(hexString: "#0D4058")

        // MARK: - Ocean

        public let ocean30 = Color(hexString: "#5694EB")
        public let ocean35 = Color(hexString: "#4187E8")
        public let ocean40 = Color(hexString: "#317DE6")
        public let ocean45 = Color(hexString: "#2573DF")
        public let ocean50 = Color(hexString: "#236DD3")
        public let ocean57 = Color(hexString: "#2063C1")
        public let ocean70 = Color(hexString: "#1C57A8")
        public let ocean90 = Color(hexString: "#17478B")
        public let ocean110 = Color(hexString: "#133B72")

        // MARK: - Violet

        public let violet30 = Color(hexString: "#B57FCC")
        public let violet35 = Color(hexString: "#AC6FC6")
        public let violet40 = Color(hexString: "#9E58BD")
        public let violet45 = Color(hexString: "#9E58BD")
        public let violet50 = Color(hexString: "#994FB9")
        public let violet57 = Color(hexString: "#9242B4")
        public let violet70 = Color(hexString: "#7F399E")
        public let violet90 = Color(hexString: "#682F82")
        public let violet110 = Color(hexString: "#56276B")

        // MARK: - Plum

        public let plum30 = Color(hexString: "#D473B1")
        public let plum35 = Color(hexString: "#CE60A7")
        public let plum40 = Color(hexString: "#CA529F")
        public let plum45 = Color(hexString: "#C54396")
        public let plum50 = Color(hexString: "#C1368F")
        public let plum57 = Color(hexString: "#BA2083")
        public let plum70 = Color(hexString: "#A31C73")
        public let plum90 = Color(hexString: "#87175F")
        public let plum110 = Color(hexString: "#70134F")

        // MARK: - Stone

        public let stone30 = Color(hexString: "#939393")
        public let stone35 = Color(hexString: "#878787")
        public let stone40 = Color(hexString: "#7F7F7F")
        public let stone45 = Color(hexString: "#767676")
        public let stone50 = Color(hexString: "#6F6F6F")
        public let stone57 = Color(hexString: "#666666")
        public let stone70 = Color(hexString: "#585858")
        public let stone90 = Color(hexString: "#494949")
        public let stone110 = Color(hexString: "#3C3C3C")
    }
}
