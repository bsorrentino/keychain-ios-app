//
//  App+Version.swift
//  KeyChainX
//
//  Created by softphone on 29/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit

//
// @see https://www.hackingwithswift.com/example-code/system/how-to-read-your-apps-version-from-your-infoplist-file
//
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
