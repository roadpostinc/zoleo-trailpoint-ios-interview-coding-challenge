//
//  Date+WireFormat.swift
//  TrailPoint
//

import Foundation

extension Date {
    init(millisecondsSince1970 milliseconds: Int64) {
        self.init(timeIntervalSince1970: Double(milliseconds) / 1000)
    }
}
