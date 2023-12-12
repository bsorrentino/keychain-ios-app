//
//  CopyToClipboardButton.swift
//  
//
//  Created by Bartolomeo Sorrentino on 21/10/23.
//

import SwiftUI

/// A button view that allows users to copy a specified value to the clipboard.
public struct CopyToClipboardButton: View {
    
    /// The value to be copied to the clipboard.
    var value: String
    
    /// A state indicating whether the task of copying to the clipboard is complete.
    @State var taskIsComplete = false
    
    /// Initializes a new `CopyToClipboardButton` with the specified value.
    /// - Parameter value: The value to be copied to the clipboard.
    public init(value: String) {
        self.value = value
    }
    
    /// The body of the `CopyToClipboardButton` view.
    public var body: some View {
        Button(action: {
            // Copy the value to the clipboard based on the platform.
            #if os(iOS)
                UIPasteboard.general.string = self.value
            #elseif os(macOS)
                NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                NSPasteboard.general.setString(self.field, forType: .string)
            #endif
            // Toggle the task completion state.
            taskIsComplete.toggle()
            // Log the action.
            logger.debug("copied to clipboard!")
        }) {
            // Display an image indicating the copy action.
            Image(systemName: "doc.on.clipboard")
        }
        // Apply a button style.
        .buttonStyle(ScaleButtonStyle())
        // Apply sensory feedback based on task completion.
        .modifier(SensoryFeedback(taskIsComplete: $taskIsComplete))
    }
}

    
/// A view modifier that provides sensory feedback based on task completion.
struct SensoryFeedback: ViewModifier {
    /// A binding to determine if the task is complete.
    @Binding var taskIsComplete: Bool
    
    /// Provides sensory feedback for iOS 17 and above.
    /// - Parameter content: The content view to which the feedback should be applied.
    /// - Returns: A view with sensory feedback applied.
    @available(iOS 17, *)
    @ViewBuilder
    func sensoryFeedback_iOS17(_ content: Content) -> some View {
        content.sensoryFeedback(.success, trigger: taskIsComplete)
    }
    
    /// The body of the view modifier.
    /// - Parameter content: The content view to which the feedback should be applied.
    /// - Returns: A view with sensory feedback or a notification feedback based on the iOS version.
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            sensoryFeedback_iOS17(content)
        }
        else {
            content.onChange(of: taskIsComplete, perform: { value in
                if value {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            })
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
