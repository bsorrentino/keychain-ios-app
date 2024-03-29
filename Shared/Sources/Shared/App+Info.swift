//
//  App+Version.swift
//  KeyChainX
//
//  Created by softphone on 29/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation


//
// @see https://www.hackingwithswift.com/example-code/system/how-to-read-your-apps-version-from-your-infoplist-file
//
public func appVersion() -> String {

    if let result = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        
        if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "\(result) (\(build))"
        }
        return result
    }
    
    return "no version"
}

public func appName() -> String {
    
    if let result = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
        
        return result
    }
    
    return "KeyChainX"
}
