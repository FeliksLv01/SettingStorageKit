//
//  SettingStorage.swift
//  SettingStorageKit
//
//  Created by FeliksLv on 2023/3/25.
//

import Foundation
@preconcurrency import MMKV

public struct AppSettings: Sendable {
    public struct Keys: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    private static var mmkv: MMKV? = MMKV(mmapID: "__global__")

    public static func initialize(groupIdentifier: String? = nil) {
        guard let groupIdentifier = groupIdentifier else {
            MMKV.initialize(rootDir: nil)
            return
        }
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier)
        {
            let mmkvPath = groupURL.path
            MMKV.initialize(rootDir: nil, groupDir: mmkvPath, logLevel: .warning)
        }
    }

    @propertyWrapper
    public struct Storage<T: Codable> {
        let key: Keys
        let defaultValue: T
        public var wrappedValue: T {
            get {
                MMKVAccessor.value(
                    forKey: key.rawValue, defaultValue: defaultValue, mmkv: AppSettings.mmkv)
            }
            set { MMKVAccessor.set(newValue, forKey: key.rawValue, mmkv: AppSettings.mmkv) }
        }

        public init(key: Keys, defaultValue: T) {
            self.defaultValue = defaultValue
            self.key = key
        }

        public init(key: Keys) where T: ExpressibleByNilLiteral {
            self.key = key
            self.defaultValue = nil
        }
    }

    public static func set<T: Codable>(_ value: T, forKey key: String) {
        MMKVAccessor.set(value, forKey: key, mmkv: AppSettings.mmkv)
    }

    public static func value<T: Codable>(forKey key: String, defaultValue: T) -> T {
        return MMKVAccessor.value(forKey: key, defaultValue: defaultValue, mmkv: AppSettings.mmkv)
    }

    public static func clearAll() {
        MMKVAccessor.clearAll(mmkv: AppSettings.mmkv)
    }
}

public class UserSettings: NSObject {
    private static var mmkv: MMKV?
    public struct Keys: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    @propertyWrapper
    public struct Storage<T: Codable> {
        public init(key: Keys, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }

        let key: Keys
        let defaultValue: T

        public var wrappedValue: T {
            get {
                assert(initializedFlag)
                return MMKVAccessor.value(
                    forKey: key.rawValue, defaultValue: defaultValue, mmkv: UserSettings.mmkv)
            }
            set {
                assert(initializedFlag)
                MMKVAccessor.set(newValue, forKey: key.rawValue, mmkv: UserSettings.mmkv)
            }
        }
    }

    private static var initializedFlag = false
    private static let initializedOnce: () = {
        initializedFlag = true
    }()

    @objc public static func changeUser(with userId: String?) {
        assert(Thread.isMainThread)

        let _ = initializedOnce

        if let userId = userId {
            mmkv = MMKV(mmapID: "user.\(userId)")
        } else {
            mmkv = nil
        }
    }

    // 防止崩溃（默认的实现会引起 NSUndefinedKeyException）
    override public class func value(forUndefinedKey key: String) -> Any? {
        let errorMessage = "UserSettings: Cannot Find Value for UndefinedKey <\(key)>"
        assertionFailure(errorMessage)
        return nil
    }

    override public class func setValue(_ value: Any?, forUndefinedKey key: String) {
        let errorMessage =
            "UserSettings: Cannot Set Value <\(String(describing: value))> for UndefinedKey <\(key)>"
        assertionFailure(errorMessage)
    }
}

// 如何判断范型可空

// https://forums.swift.org/t/how-to-check-if-a-value-of-a-generic-type-is-nil/50631

/// 提供Codable读取方法
private struct MMKVAccessor {
    /// 支持nil，如果为nil，将会移除已经存储的数据
    static func set<T: Codable>(_ value: T?, forKey key: String, mmkv: MMKV?) {
        guard let mmkv = mmkv else {
            assertionFailure()
            return
        }
        guard value != nil else {
            mmkv.removeValue(forKey: key)
            return
        }

        // 类型处理

        if let value = value as? Bool {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Int {
            mmkv.set(Int64(value), forKey: key)
        } else if let value = value as? Int32 {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Int64 {
            mmkv.set(value, forKey: key)
        } else if let value = value as? UInt {
            mmkv.set(UInt64(value), forKey: key)
        } else if let value = value as? UInt32 {
            mmkv.set(value, forKey: key)
        } else if let value = value as? UInt64 {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Float {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Double {
            mmkv.set(value, forKey: key)
        } else if let value = value as? String {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Date {
            mmkv.set(value, forKey: key)
        } else if let value = value as? Data {
            mmkv.set(value, forKey: key)
        } else {
            // Codable处理
            do {
                let data = try JSONEncoder().encode(value)
                mmkv.set(data, forKey: key)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    static func value<T: Codable>(forKey key: String, defaultValue: T, mmkv: MMKV?) -> T {
        guard let mmkv = mmkv else {
            return defaultValue
        }

        if !mmkv.contains(key: key) {
            return defaultValue
        }

        if T.self == Int.self || T.self == Int?.self {
            return Int(mmkv.int64(forKey: key)) as? T ?? defaultValue
        } else if T.self == Int64.self || T.self == Int64?.self {
            return mmkv.int64(forKey: key) as? T ?? defaultValue
        } else if T.self == Int32.self || T.self == Int32?.self {
            return mmkv.int32(forKey: key) as? T ?? defaultValue
        } else if T.self == UInt.self || T.self == UInt?.self {
            return mmkv.uint64(forKey: key) as? T ?? defaultValue
        } else if T.self == UInt64.self || T.self == UInt64?.self {
            return mmkv.uint64(forKey: key) as? T ?? defaultValue
        } else if T.self == UInt32.self || T.self == UInt32?.self {
            return mmkv.uint32(forKey: key) as? T ?? defaultValue
        } else if T.self == Float.self || T.self == Float?.self {
            return mmkv.float(forKey: key) as? T ?? defaultValue
        } else if T.self == Double.self || T.self == Double?.self {
            return mmkv.double(forKey: key) as? T ?? defaultValue
        } else if T.self == CGFloat.self || T.self == CGFloat?.self {
            return CGFloat(mmkv.double(forKey: key)) as? T ?? defaultValue
        } else if T.self == Bool.self || T.self == Bool?.self {
            return mmkv.bool(forKey: key) as? T ?? defaultValue
        } else if T.self == String.self || T.self == String?.self {
            return mmkv.string(forKey: key) as? T ?? defaultValue
        } else if T.self == Date.self || T.self == Date?.self {
            return mmkv.date(forKey: key) as? T ?? defaultValue
        } else if T.self == Data.self || T.self == Data?.self {
            return mmkv.data(forKey: key) as? T ?? defaultValue
        } else {
            guard let data = mmkv.data(forKey: key) else {
                return defaultValue
            }
            do {
                // 想把范型类型转成具体的类型
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                assertionFailure("\(error)")
                return defaultValue
            }
        }
    }

    static func clearAll(mmkv: MMKV?) {
        mmkv?.clearAll()
    }
}
