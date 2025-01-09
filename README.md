# SettingStorageKit

An Application/User Settings framework implemented using MMKV.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```swift
import SettingStorageKit

extension AppSettings.Keys {
    static let isFirstOpen = AppSettings.Keys(rawValue: "isFirstOpen")
}

extension AppSettings {
    @Storage(key: .isFirstOpen, defaultValue: true)
    static var isFirstOpen: Bool
}

print(AppSettings.isFirstOpen)
AppSettings.isFirstOpen = false
```
