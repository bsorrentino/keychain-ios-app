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
    
    @Binding var hidden:Bool
    
    @ObservedObject var field:FieldValidator<String>
    
    init( value:Binding<String>, checker:Binding<FieldChecker>, hidden:Binding<Bool>, validator:@escaping Validator ) {
        self.field = FieldValidator(value, checker:checker, validator:validator )
        self._hidden = hidden
    }

    var body: some View {
        
        VStack {
            Group {
                if( hidden ) {
                    SecureField( "give me the password", text:$field.value)
                }
                else {
                    TextField( "give me the password", text:$field.value)
                }
            }
        }
        .onAppear {
            self.field.doValidate()
        }

    }
}


private struct HideToggleButton : View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @Binding var hidden:Bool
    
    public init( _ hidden:Binding<Bool> ) {
        self._hidden = hidden
    }
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
    @Binding var passwordCheck:FieldChecker
    @State var hidden:Bool = true

    private let strikeWidth:CGFloat = 0.5
    
    
    var body: some View {
        
         //VStack(alignment: .leading) {
             
            HStack {
                PasswordToggleField( value:$value,
                                  checker:$passwordCheck,
                                  hidden:$hidden ) { v in
                     if( v.isEmpty ) {
                         return "password cannot be empty"
                     }
                     return nil
                }
                .autocapitalization(.none)
                HideToggleButton( $hidden )
                CopyToClipboardButton( value:self.value )
                

            }
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
             .overlay(
                 ValidatorMessageInline( message:passwordCheck.errorMessage ), alignment: .bottom
             )


        //}.buttonStyle(PlainButtonStyle())
        
    }
}
