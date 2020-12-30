//
//  KeyboardGeometry.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 07/12/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

class KeyboardGeometryReader: ObservableObject {
    @Published private(set) var size = CGSize()

    init() {
        self.listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main)
                        { (notification) in
                            guard let userInfo = notification.userInfo,
                            let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                                
                            self.size = keyboardRect.size
                        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: .main)
                        { (notification) in
                            self.size = CGSize()
                        }
    }
}
