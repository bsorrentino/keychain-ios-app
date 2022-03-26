//
//  KeyItemForm+Password.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/01/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
import FieldValidatorLibrary
import OSLog

private struct PasswordToggleField : View {
    typealias Validator = (String) -> String?
    
    @Binding var value:String
    var hidden:Bool
 
    var body: some View {
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


private struct HideToggleButton : View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var hidden:Bool
    
    var body: some View {
        Button( action: {
            logger.trace("toggle hidden!")
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

    }
}

struct PasswordField : View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var value:String
    @ObservedObject var passwordCheck:FieldChecker2<String>
    @State var hidden:Bool = true

    private let strikeWidth:CGFloat = 0.5
    
    
    var body: some View {
        HStack {
            PasswordToggleField( value:$value.onValidate(checker: passwordCheck) { v in
                 if( v.isEmpty ) {
                     return "password cannot be empty"
                 }
                 return nil
            }, hidden: hidden)
            .autocapitalization(.none)
            HideToggleButton( hidden: $hidden )
            CopyToClipboardButton( value:self.value )
            

        }
        .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
        .modifier( ValidatorMessageModifier( message:passwordCheck.errorMessage ) )
    }
}
