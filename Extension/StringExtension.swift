//
//  StringExtension.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/26.
//

import Foundation


extension String {
    func convertTimeStampToHourMinute() -> String {
        let hourStartIdx = self.index(self.startIndex, offsetBy: 8)
        let hourEndIdx = self.index(self.startIndex, offsetBy: 9)
        let minuteStartIdx = self.index(self.startIndex, offsetBy: 10)
        let minuteEndIdx = self.index(self.startIndex, offsetBy: 11)
        let hour = self[hourStartIdx...hourEndIdx]
        let minute = self[minuteStartIdx...minuteEndIdx]
        return "\(hour):\(minute)"
    }
    
    func convertTimeStampToMonthDay() -> String {
        let monthStartIdx = self.index(self.startIndex, offsetBy: 4)
        let monthEndIdx = self.index(self.startIndex, offsetBy: 5)
        let dayStartIdx = self.index(self.startIndex, offsetBy: 6)
        let dayEndIdx = self.index(self.startIndex, offsetBy: 7)
        let month = self[monthStartIdx...monthEndIdx]
        let day = self[dayStartIdx...dayEndIdx]
        return "\(month)월 \(day)일"
    }
}
