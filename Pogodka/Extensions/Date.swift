//
//  Date.swift
//  Pogodka
//
//  Created by Михаил Звягинцев on 29.09.2021.
//

import Foundation

extension Date {

    func allowUpdate(updateIntervalSec: Double) -> Bool {
        return (Date().timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate) > updateIntervalSec
    }
}
