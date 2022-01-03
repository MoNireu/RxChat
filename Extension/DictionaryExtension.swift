//
//  DictionaryExtension.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/03.
//

import Foundation


extension Dictionary where Value: Hashable {
    func swap() -> [Value: Key]? {
        let setOfDictionaryKeys = Set(self.keys)
        guard self.count == setOfDictionaryKeys.count else { return nil }
        var dic = Dictionary<Value, Key>()
        for (key, value) in self {
            dic.updateValue(key, forKey: value)
        }
        return dic
    }
}
