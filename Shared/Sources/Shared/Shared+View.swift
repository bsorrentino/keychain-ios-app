//
//  Shared+View.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 13/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
import OSLog

public struct CopyToClipboardButton : View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var copied = false
    var value:String
    
    public init( value:String ) {
        self.value = value
    }
    public var body: some View {
        Button( action: {
            withAnimation( Animation.default.speed(0.1) ) {
                logger.debug("copy to clipboard!")
                #if os(iOS)
                UIPasteboard.general.string = self.value
                #elseif os(macOS)
                NSPasteboard.general.declareTypes([ NSPasteboard.PasteboardType.string ], owner: nil)
                NSPasteboard.general.setString(self.value, forType: .string)
                #endif
                self.copied = true
            }
            withAnimation( Animation.default.delay(0.1)) {
                 self.copied = false
            }
        
         }) {

            Group {
                
                if( self.copied ) {
                    Image( systemName: "doc.on.clipboard.fill").colorInvert()
                }
                else {
                    Image( systemName: "doc.on.clipboard")
                        
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
    }
}
