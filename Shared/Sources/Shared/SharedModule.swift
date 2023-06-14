//
//  SharedServices.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 29/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation

// MARK: Shared namespace

public class SharedModule {}


public var isInPreviewMode:Bool {
    (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil)
}

#if targetEnvironment(simulator)
  // Simulator!
public let isRunningOnSimulator = true
#else
public let isRunningOnSimulator = false
#endif

