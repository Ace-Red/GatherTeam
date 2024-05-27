//
//  Date+Extension.swift
//  GatherTeam
//
//

import Foundation

extension Int {
    static func generateDateFromTimestamp(with timestamp: Int) -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        var sevenDaysFromNow = date
        while sevenDaysFromNow < Date() {
            if let date = Calendar.current.date(byAdding: .day, value: 7, to: sevenDaysFromNow) {
                sevenDaysFromNow = date
            }
        }
        
        return sevenDaysFromNow
    }
}
