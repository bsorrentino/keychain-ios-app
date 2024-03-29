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
import Shared

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
