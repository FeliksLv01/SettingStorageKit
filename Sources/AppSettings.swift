//
//  AppSettings.swift
//  UniStorage
//
//  Created by FeliksLv on 2023/3/25.
//

import Foundation

public extension AppSettings {
    enum Keys: String {
        case none
    }
    
    @Storage(key: .none, defaultValue: "测试用")
    static var none: String
}
