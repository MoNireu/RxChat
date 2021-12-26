//
//  TimeStampConvertUtility.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/26.
//

import Foundation


class TimeStampConvertUtility {
    static let shared = TimeStampConvertUtility()
    
    func convertTimeStampToHourMinute(_ timeStamp: String) -> String {
        let hourStartIdx = timeStamp.index(timeStamp.startIndex, offsetBy: 8)
        let hourEndIdx = timeStamp.index(timeStamp.startIndex, offsetBy: 9)
        let minuteStartIdx = timeStamp.index(timeStamp.startIndex, offsetBy: 10)
        let minuteEndIdx = timeStamp.index(timeStamp.startIndex, offsetBy: 11)
        let hour = timeStamp[hourStartIdx...hourEndIdx]
        let minute = timeStamp[minuteStartIdx...minuteEndIdx]
        return "\(hour):\(minute)"
    }
}
