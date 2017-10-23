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
