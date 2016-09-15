//
//  MeterTable.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//
//  A Swift port of Apple's MeterTable. https://developer.apple.com/library/ios/samplecode/avTouch/Introduction/Intro.html#//apple_ref/doc/uid/DTS40008636-Intro-DontLinkElementID_2

import Foundation
import SoLazy

private func DBtoAmp(db: Double) -> Double {
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