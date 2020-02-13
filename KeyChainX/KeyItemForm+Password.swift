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

    @Binding var value:String
    @Binding var passwordCheck:FieldChecker
    @State var hidden:Bool = true
    
    private let strikeWidth:CGFloat = 0.5
    
    var body: some View {
        
         VStack(alignment: .leading) {
             
             HStack {
                 Text("Password")
                 if( !passwordCheck.valid  ) {
                     Spacer()
                     Text( passwordCheck.errorMessage ?? "" )
                         .fontWeight(.light)
                         .font(.footnote)
                         .foregroundColor(Color.red)

                 }

             }
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
                    .foregroundColor(Color.black)
                 }

            }
             .padding( 10.0 )
             .overlay( RoundedRectangle(cornerRadius: 10)
                         .stroke(lineWidth: strikeWidth )
                         .foregroundColor(passwordCheck.valid ? Color.black : Color.red)
             )


         }
    }
}
