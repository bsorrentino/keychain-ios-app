//
//  SwiftUI+Condition.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 03/02/22.
//  Copyright © 2022 Bartolomeo Sorrentino. All rights reserved.
//

//
//  SwiftUI+Condition.swift
//  slides
//
//  Created by softphone on 14/07/21.
//  Copyright © 2021 bsorrentino. All rights reserved.
//

import SwiftUI

// @ref https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - modifier: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View>(_ condition: Bool, modifier: (Self) -> Content) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}
