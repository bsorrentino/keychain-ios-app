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

struct PasswordField : View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var value:String
    @Binding var passwordCheck:FieldChecker
    @State var hidden:Bool = true
    @State var copied:Bool = false

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
                
                Button( action: {
                    print("toggle hidden!")
                    self.hidden.toggle()
                 }) {
                    Group {
                        if( hidden ) {
                            Image( systemName: "eye.slash")
                        }
                        else {
                            Image( systemName: "eye")
                        }
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                 }
                ButtonCopyToClipboard
                

            }
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
             .overlay(
                 ValidatorMessageInline( message:passwordCheck.errorMessage ), alignment: .bottom
             )


        //}.buttonStyle(PlainButtonStyle())
        
    }
}

// MARK: -
// MARK: Clipboard
extension PasswordField {
    
    var ButtonCopyToClipboard:some View {
        
        Button( action: {
            withAnimation( Animation.default.speed(0.1) ) {
                print("copy to clipboard!")
                UIPasteboard.general.string = self.value
                self.copied = true
            }
            withAnimation( Animation.default.delay(0.1)) {
                 self.copied = false
            }
        
         }) {

            Group {
                if( self.copied ) {
                    Image( systemName: "doc.on.clipboard").colorInvert()
                }
                else {
                    Image( systemName: "doc.on.clipboard")
                        
                }
            }.foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        }.disabled( !passwordCheck.valid )

    }
}
