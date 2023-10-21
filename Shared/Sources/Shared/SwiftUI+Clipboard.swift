//
//  SwiftUIView.swift
//  
//
//  Created by Bartolomeo Sorrentino on 21/10/23.
//

import SwiftUI

public struct CopyToClipboardButton : View {
    
    
    var value:String
    
    public init( value:String ) {
        self.value = value
    }
    
    public var body: some View {
        Button( action: {
#if os(iOS)
            UIPasteboard.general.string = self.value
#elseif os(macOS)
            NSPasteboard.general.declareTypes([ NSPasteboard.PasteboardType.string ], owner: nil)
            NSPasteboard.general.setString(self.value, forType: .string)
#endif
            logger.debug("copied to clipboard!")
        }) {
            
            Image( systemName: "doc.on.clipboard")
        }
        .buttonStyle(ScaleButtonStyle())
        .modifier( SensoryFeedback() )
    }
}
    
struct SensoryFeedback: ViewModifier {
    @State private var taskIsComplete = false
    
    @available( iOS 17, * )
    func sensoryFeedback_iOS17(_ content: Content) -> some View {
        return content.sensoryFeedback(.success, trigger: taskIsComplete)
    }
    
    func body(content: Content) -> some View {
        if #available( iOS 17, *) {
            sensoryFeedback_iOS17(content)
        }
    }
}

#Preview {
    VStack {
        Divider()
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            HStack {
                let s = switch( colorScheme ) {
                case .dark:
                    "dark"
                case .light:
                    "light"
                default:
                    "unknown"
                }
                Text( "\(s)" )
                CopyToClipboardButton( value: "copy to clipboard" )
                    .preferredColorScheme(colorScheme)
            }
            Divider()
        }
    }
}
