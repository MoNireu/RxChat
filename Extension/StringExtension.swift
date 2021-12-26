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
}
