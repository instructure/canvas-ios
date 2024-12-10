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

        let blue12 = Color(hexString: "#E0EBF5")
        let blue45 = Color(hexString: "#2B7ABC")
        let blue57 = Color(hexString: "#0E68B3")
        let blue70 = Color(hexString: "#0A5A9E")
        let blue82 = Color(hexString: "#09508C")
        let blueGradient = [Color(hexString: "#09508C"), Color(hexString: "#0A5A9E")]

        // MARK: - Green

        let green12 = Color(hexString: "#DCEEE4")
        let green45 = Color(hexString: "#03893D")
        let green57 = Color(hexString: "#027634")
        let green70 = Color(hexString: "#02672D")
        let green82 = Color(hexString: "#015B28")

        // MARK: - Orange

        let orange12 =  Color(hexString: "#FCE5D9")
        let orange30 =  Color(hexString: "#F06E26")
        let orange45 =  Color(hexString: "#CF4A00")
        let orange57 =  Color(hexString: "#B34000")
        let orange70 =  Color(hexString: "#9C3800")
        let orange82 =  Color(hexString: "#8B3200")

        // MARK: - Red

        let red12 =  Color(hexString: "#FCE4E5")
        let red45 =  Color(hexString: "#E62429")
        let red57 =  Color(hexString: "#C71F23")
        let red70 =  Color(hexString: "#AE1B1F")
        let red82 =  Color(hexString: "#9B181C")

        // MARK: - White

        let white10 =  Color(hexString: "#FFFFFF")

        // MARK: - Grey

        let grey11 = Color(hexString: "#F2F4F4")
        let grey12 = Color(hexString: "#E8EAEC")
        let grey14 = Color(hexString: "#D7DADE")
        let grey24 = Color(hexString: "#9EA6AD")
        let grey45 = Color(hexString: "#6A7883")
        let grey57 = Color(hexString: "#586874")
        let grey70 = Color(hexString: "#4A5B68")
        let grey82 = Color(hexString: "#3F515E")
        let grey100 = Color(hexString: "#334451")
        let grey125 = Color(hexString: "#273540")

        // MARK: - Black

        let black174 = Color(hexString: "#0A1B2A")

        // MARK: - Beige

        let beige10 = Color(hexString: "#FFFDFA")
        let beige11 = Color(hexString: "#FBF5ED")
        let beige12 = Color(hexString: "#FDEACC")
        let beige15 = Color(hexString: "#E3D0B2")
        let beige19 = Color(hexString: "#CAB79A")
        let beige26 = Color(hexString: "#B09F83")
        let beige35 = Color(hexString: "#97876D")
        let beige49 = Color(hexString: "#7D6F58")
        let beige69 = Color(hexString: "#645844")
        let beige100 = Color(hexString: "#4A4131")
        let beige147 = Color(hexString: "#2F271B")
        let beigeGradient = [Color(hexString: "#FFFDFA"), Color(hexString: "#FBF5ED")]

        // MARK: - Additional Primitives
        // MARK: - Rose

        let rose30 = Color(hexString: "#FB5D5D")
        let rose35 = Color(hexString: "#FA3F3F")
        let rose40 = Color(hexString: "#FA1A1A")
        let rose45 = Color(hexString: "#ED0000")
        let rose50 = Color(hexString: "#E00000")
        let rose57 = Color(hexString: "#CE0000")
        let rose70 = Color(hexString: "#B50000")
        let rose90 = Color(hexString: "#970000")
        let rose110 = Color(hexString: "#7F0000")

        // MARK: - Copper

        let copper30 = Color(hexString: "#EE6D15")
        let copper35 = Color(hexString: "#DB6414")
        let copper40 = Color(hexString: "#CD5E12")
        let copper45 = Color(hexString: "#BF5811")
        let copper50 = Color(hexString: "#B45310")
        let copper57 = Color(hexString: "#A54C0F")
        let copper70 = Color(hexString: "#90420D")
        let copper90 = Color(hexString: "#77360B")
        let copper110 = Color(hexString: "#622D09")

        // MARK: - Honey

        let honey30 = Color(hexString: "#C08A00")
        let honey35 = Color(hexString: "#B07E00")
        let honey40 = Color(hexString: "#A57600")
        let honey45 = Color(hexString: "#996E00")
        let honey50 = Color(hexString: "#916800")
        let honey57 = Color(hexString: "#856000")
        let honey70 = Color(hexString: "#745300")
        let honey90 = Color(hexString: "#5F4400")
        let honey110 = Color(hexString: "#4E3800")

        // MARK: - Forest

        let forest30 = Color(hexString: "#55A459")
        let forest35 = Color(hexString: "#409945")
        let forest40 = Color(hexString: "#319135")
        let forest45 = Color(hexString: "#27872B")
        let forest50 = Color(hexString: "#248029")
        let forest57 = Color(hexString: "#217526")
        let forest70 = Color(hexString: "#1D6621")
        let forest90 = Color(hexString: "#18541B")
        let forest110 = Color(hexString: "#144516")

        // MARK: - Aurora

        let aurora30 = Color(hexString: "#38A585")
        let aurora35 = Color(hexString: "#1E9975")
        let aurora40 = Color(hexString: "#0B9069")
        let aurora45 = Color(hexString: "#048660")
        let aurora50 = Color(hexString: "#047F5B")
        let aurora57 = Color(hexString: "#037453")
        let aurora70 = Color(hexString: "#036549")
        let aurora90 = Color(hexString: "#02533C")
        let aurora110 = Color(hexString: "#024531")

        // MARK: - Sea

        let sea30 = Color(hexString: "#37A1AA")
        let sea35 = Color(hexString: "#1E95A0")
        let sea40 = Color(hexString: "#0A8C97")
        let sea45 = Color(hexString: "#00828E")
        let sea50 = Color(hexString: "#007B86")
        let sea57 = Color(hexString: "#00717B")
        let sea70 = Color(hexString: "#00626B")
        let sea90 = Color(hexString: "#005158")
        let sea110 = Color(hexString: "#004349")

        // MARK: - Sky
        let sky30 = Color(hexString: "#4E9CC0")
        let sky35 = Color(hexString: "#3890B8")
        let sky40 = Color(hexString: "#2887B2")
        let sky45 = Color(hexString: "#197EAB")
        let sky50 = Color(hexString: "#1777A2")
        let sky57 = Color(hexString: "#156D94")
        let sky70 = Color(hexString: "#135F81")
        let sky90 = Color(hexString: "#0F4E6A")
        let sky110 = Color(hexString: "#0D4058")

        // MARK: - Ocean

        let ocean30 = Color(hexString: "#5694EB")
        let ocean35 = Color(hexString: "#4187E8")
        let ocean40 = Color(hexString: "#317DE6")
        let ocean45 = Color(hexString: "#2573DF")
        let ocean50 = Color(hexString: "#236DD3")
        let ocean57 = Color(hexString: "#2063C1")
        let ocean70 = Color(hexString: "#1C57A8")
        let ocean90 = Color(hexString: "#17478B")
        let ocean110 = Color(hexString: "#133B72")

        // MARK: - Violet

        let violet30 = Color(hexString: "#B57FCC")
        let violet35 = Color(hexString: "#AC6FC6")
        let violet40 = Color(hexString: "#9E58BD")
        let violet45 = Color(hexString: "#9E58BD")
        let violet50 = Color(hexString: "#994FB9")
        let violet57 = Color(hexString: "#9242B4")
        let violet70 = Color(hexString: "#7F399E")
        let violet90 = Color(hexString: "#682F82")
        let violet110 = Color(hexString: "#56276B")

        // MARK: - Plum

        let plum30 = Color(hexString: "#D473B1")
        let plum35 = Color(hexString: "#CE60A7")
        let plum40 = Color(hexString: "#CA529F")
        let plum45 = Color(hexString: "#C54396")
        let plum50 = Color(hexString: "#C1368F")
        let plum57 = Color(hexString: "#BA2083")
        let plum70 = Color(hexString: "#A31C73")
        let plum90 = Color(hexString: "#87175F")
        let plum110 = Color(hexString: "#70134F")

        // MARK: - Stone

        let stone30 = Color(hexString: "#939393")
        let stone35 = Color(hexString: "#878787")
        let stone40 = Color(hexString: "#7F7F7F")
        let stone45 = Color(hexString: "#767676")
        let stone50 = Color(hexString: "#6F6F6F")
        let stone57 = Color(hexString: "#666666")
        let stone70 = Color(hexString: "#585858")
        let stone90 = Color(hexString: "#494949")
        let stone110 = Color(hexString: "#3C3C3C")
    }
}
