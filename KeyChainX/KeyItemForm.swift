//
//  KeyItemDetail.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
import FieldValidatorLibrary

enum SecretInfo: Int, Hashable {
    
    case hide
    case show
}


struct PasswordToggleField : View {
    typealias Validator = (String) -> String?
    
    @Binding var secretInfo:SecretInfo
    
    @ObservedObject var field:FieldValidator<String>
    
    init( value:Binding<String>, checker:Binding<FieldChecker>, secretInfo:Binding<SecretInfo>, validator:@escaping Validator ) {
        self.field = FieldValidator(value, checker:checker, validator:validator )
        self._secretInfo = secretInfo
    }

    var body: some View {
        
        VStack {
            Group {
                if( secretInfo == .hide ) {
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

extension SecretInfo {
    
    var text:String {
        switch( self ) {
        case .hide: return "***"
        case .show: return "abc"
        }
    }
}



struct KeyEntityForm : View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var item:KeyItem
    
    @State var secretInfo:SecretInfo = .hide
    
    @State private var pickUsernameFromMail = false
    
    private let bg = Color(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, opacity: 0.2)
                    //Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    private let strikeWidth:CGFloat = 0.5
    
    init() {
        self.item = KeyItem()
    }

    init( entity:KeyEntity ) {
        self.item = KeyItem( entity:entity )
    }

    func mnemonicInput() -> some View  {
        
        VStack(alignment: .leading) {
            HStack {
                Text("mnemonic")
                if( !item.mnemonicCheck.valid  ) {
                    Spacer()
                    Text( item.mnemonicCheck.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            
            TextFieldWithValidator( title: "give me the unique name of key",
                                    value: $item.mnemonic,
                                    checker:$item.mnemonicCheck ) { v in
                
                if( v.isEmpty ) {
                    return "mnemonic cannot be empty"
                }
                
                return nil
            }
            .autocapitalization(.allCharacters)
            .padding(10.0)
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth)
                    .foregroundColor(item.mnemonicCheck.valid ? Color.black : Color.red)
            )

        }
            

    }
    
    func userInput() -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("username")
                if( !item.usernameCheck.valid  ) {
                    Spacer()
                    Text( item.usernameCheck.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            
            HStack {
                TextFieldWithValidator( title:"give me the username ?",
                                        value: $item.username,
                                        checker:$item.usernameCheck ) { v in
                    
                    if( v.isEmpty ) {
                        return "username cannot be empty"
                    }
                    
                    //print( "validate username \(v) - \(self.pickUsernameFromMail)")
                    
                    if( self.pickUsernameFromMail ) {
                        self.item.mail = v
                    }
                    return nil
                }
                //.padding(.all)
                //.border( Color.black )
                //.background(bg)
                .autocapitalization(.none)
                NavigationLink( destination: EmailList( value: $item.username_mail_setter), isActive:$pickUsernameFromMail  ) {
                        EmptyView()
                }
                .frame( width:0, height:0)
                Button( action: {
                    self.pickUsernameFromMail = true
                }) {
                    Image( systemName: "envelope.circle").foregroundColor(Color.black)
                }


            }
            .padding( 10.0 )
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth)
                    .foregroundColor(item.usernameCheck.valid ? Color.black : Color.red)
            )

        }


    }

    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                Text("Password")
                if( !item.passwordCheck.valid  ) {
                    Spacer()
                    Text( item.passwordCheck.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            
       
            PasswordToggleField( value:$item.password,
                                 checker:$item.passwordCheck,
                                 secretInfo:$secretInfo ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    return nil
            }
            .autocapitalization(.none)
            .padding( 10.0 )
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth )
                    .foregroundColor(item.usernameCheck.valid ? Color.black : Color.red)
            )


        }

    }

    
    var body: some View {
        NavigationView {
            Form {
                

                if( item.isNew ) {
                    
                    Section {
                        mnemonicInput()
                    }

                }

                Section {
                    
                    userInput()
                    
                    passwordInput()
                                        
                }
                
                Section {
                    
                    GroupField( value:$item.groupPrefix )

                    EmailField( value:$item.mail )
                    
                    NoteField( value:$item.note)
                    
                }
            }
            .navigationBarTitle( Text( item.mnemonic.uppercased()), displayMode: .inline  )
            .navigationBarItems(trailing:
                HStack {
                    Picker( selection: $secretInfo, label: EmptyView() ) {
                        Image( systemName: "eye.slash").tag(SecretInfo.hide)
                        //Text(SecretInfo.hide.text).tag(SecretInfo.hide)
                        Image( systemName: "eye").tag(SecretInfo.show)
                        //Text(SecretInfo.show.text).tag(SecretInfo.show)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    Spacer(minLength: 15)
                    
                    Button( "save", action: {
                        print( "Save\n mnemonic: \(self.item.mnemonic)\n username: \(self.item.username)" )
                        
                        do {
                            try self.item.save( context: self.managedObjectContext )
                        }
                        catch {
                            if( self.item.isNew ) {
                                print( "error inserting new key \(error)" )
                            }
                            else {
                                print( "error updating new key \(error)" )
                            }
                        }
                        
                        self.presentationMode.wrappedValue.dismiss()
                        
                    })
                    .disabled( !item.checkIsValid )
                    
                }
            )
        } // NavigationView
        
    }
}

#if DEBUG
import KeychainAccess

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        
        KeyEntityForm()
        
        
    }
}
#endif
    
