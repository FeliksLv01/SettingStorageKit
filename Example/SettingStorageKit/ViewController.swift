//
//  ViewController.swift
//  SettingStorageKit
//
//  Created by 49094905 on 03/25/2023.
//  Copyright (c) 2023 49094905. All rights reserved.
//

import UIKit
import SettingStorageKit

extension AppSettings.Keys {
    static let isFirstOpen = AppSettings.Keys(rawValue: "isFirstOpen")
}

extension AppSettings {
    @Storage(key: .isFirstOpen, defaultValue: true)
    static var isFirstOpen: Bool
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Home"
        view.backgroundColor = .white
        
        print(AppSettings.isFirstOpen)
        AppSettings.isFirstOpen = false
    }
}

