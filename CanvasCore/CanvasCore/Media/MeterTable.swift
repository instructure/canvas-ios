//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation


private func DBtoAmp(_ db: Double) -> Double {
    return pow(10.0, 0.05 * db)
}

struct MeterTable {
    let minDecibels: Double
    let scaleFactor: Double
    let table: [Double]
    
    let meterTicks: Int

    init(meterTicks: Int) {
        self.meterTicks = meterTicks
        minDecibels = -80.0
        let root = 3.0
        let tableSize = 128
        
        let decibelResolution = minDecibels/Double(tableSize - 1)
        scaleFactor = 1/decibelResolution
        
        if minDecibels >= 0.0 {
            table = []
            ❨╯°□°❩╯⌢"decibels are negative yo"
        }
        
        let minAmp = DBtoAmp(minDecibels)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        let rroot = 1.0 / root
        
        table = (1 ..< tableSize).map { i in
            let decibels = Double(i) * decibelResolution
            let amp = DBtoAmp(decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            return pow(adjAmp, rroot)
        }
    }
    
    /** returns a value from 0 to 1 table's range
     */
    subscript(decibels: Double) -> Int {
        if (decibels < minDecibels) { return  0 }
        if (decibels >= 0.0) { return meterTicks }
        let index = Int(decibels * scaleFactor)
        let value = table[index]
        return Int(round(value * Double(meterTicks)))
    }
}
