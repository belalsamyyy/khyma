//
//  Int+Extensions.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation

extension Int {
    
    // convert seconds(Int) into hours and minutes and seconds
    func hoursAndMinutesAndSeconds() -> (Int, Int, Int) {
        let minutes = self / 60
        return (minutes / 60, minutes % 60, self % 60)
    }
    
    // 1 -> 01
    func twoDigits() -> String {
        return String(format: "%02d", self)
    }
    
    func toMinutes() -> Int {
        return self * 60
    }
}
