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

// https://www.simpleswiftguide.com/advanced-swiftui-button-styling-and-animation/
struct ScaleButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.3 : 1.0)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
    }
}

public struct PasswordToggleField : View {
    
    @Binding var value:String
    var hidden:Bool
 
    public init( value: Binding<String>, hidden: Bool ) {
        self._value = value
        self.hidden = hidden
    }
    
    public var body: some View {
        Group {
            if( hidden ) {
                SecureField( "give me the password", text:$value)
            }
            else {
                TextField( "give me the password", text:$value)
            }
        }
    }
}


public struct HideToggleButton : View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var hidden:Bool
    
    public init( hidden: Binding<Bool> ) {
        self._hidden = hidden
    }

    public var body: some View {
        Button( action: {
            self.hidden.toggle()
         }) {
            Group {
                if( self.hidden ) {
                    Image( systemName: "eye.slash")
                }
                else {
                    Image( systemName: "eye")
                }
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
         }
         .buttonStyle(PlainButtonStyle())

    }
}


struct SharedView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {

            HStack {
                PasswordToggleField( value: .constant("test"), hidden: true)
                HideToggleButton( hidden: .constant(true) )
                CopyToClipboardButton( value: "test" )
                

            }
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
            
            HStack {
                PasswordToggleField( value: .constant("test"), hidden: false)
                HideToggleButton( hidden: .constant(false) )
                CopyToClipboardButton( value: "test" )
                

            }
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )

        }

    }
}
