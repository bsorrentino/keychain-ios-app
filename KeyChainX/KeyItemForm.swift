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
                    SecureField( "password", text:$field.value)
                }
                else {
                    TextField( "password", text:$field.value)
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

struct EmailField : View {
    
    @Binding var value:String

    
    var body: some View {
        NavigationLink( destination: EmailList( value: $value) ) {
            HStack {
                Image( systemName: "envelope.circle")
                if( value.isEmpty ) {
                    Text( "tap to choose email" )
                        .foregroundColor(.gray)
                        .italic()
                }
                else {
                    Text(value )
                }
            }
        }
    }

    
}

struct NoteField : View {
    
    @Binding var value:String

    func message() -> some View {
        if( self.value.isEmpty ) {
            return Text( "tap to insert note" )
                .foregroundColor(.gray)
                .italic()
        }
        else {
            return Text(self.value)
                
        }

    }
    var body: some View {
        NavigationLink( destination: KeyItemNote( value: $value) ) {
            HStack(alignment: .center) {
                Image( systemName: "doc.circle")
                GeometryReader { geometry in
                    self.message()
                    .frame(width: geometry.size.width ,
                           height: geometry.size.height,
                           alignment: .leading)
                }
            }
        }
    }

    
}



struct KeyItemForm : View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var keys:ApplicationKeys;

    @ObservedObject var item:KeyItem
    
    @State var secretInfo:SecretInfo = .hide
    
    @State var userValid        = FieldChecker()
    @State var mnemonicValid    = FieldChecker()
    @State var passwordValid    = FieldChecker()

    func mnemonicInput() -> some View  {
        
        VStack(alignment: .leading) {
            Text("mnemonic")
            TextFieldWithValidator( value: $item.id, checker:$mnemonicValid ) { v in
                
                if( v.isEmpty ) {
                    return "mnemonic cannot be empty"
                }
                
                return nil
            }
            .padding(.all)
            .border( mnemonicValid.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.allCharacters)
    
            if( !mnemonicValid.valid  ) {
                Text( mnemonicValid.errorMessage ?? "" )
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)

            }
        }
            

    }
    
    func userInput() -> some View {
        
        VStack(alignment: .leading) {
            Text("username")
            TextFieldWithValidator( value: $item.username, checker:$userValid ) { v in
                
                if( v.isEmpty ) {
                    return "username cannot be empty"
                }
                
                return nil
            }
            .padding(.all)
            .border( userValid.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            
            if( !userValid.valid  ) {
                Text( userValid.errorMessage ?? "" )
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)

            }
        }


    }

    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            Text("Password")
            PasswordToggleField( value:$item.password, checker:$passwordValid, secretInfo:$secretInfo ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    return nil
            }
            .padding(.all)
            .border( passwordValid.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            
            if( !passwordValid.valid  ) {
                Text( passwordValid.errorMessage ?? "" )
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)

            }

        }

    }

    
    var body: some View {
        NavigationView {
            Form {
                

                if( item.state == KeyItem.State.new ) {
                    Section {
                        
                        mnemonicInput()
                        
                    }

                }

                Section {
                    
                    userInput()
                    
                    passwordInput()
                                        
                }
                
                Section {
                    
                    EmailField( value:$item.email )
                    
                    NoteField( value:$item.note)
                    
                }
            }
            .navigationBarTitle( Text("\(item.id.uppercased())"), displayMode: .inline  )
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
                        print( "Save \(self.item.username)" )

                        if ( self.item.state == .new ) {
                            self.keys.items.append(self.item)
                        }
                        else if ( self.item.state == .neutral ) {
                            self.item.state = .updated
                        }
                        self.keys.objectWillChange.send( self.item )

                        print( "appData.items.count: \(self.keys.items.count)" )
                        self.presentationMode.wrappedValue.dismiss()
                        
                    })
                    .disabled( !(mnemonicValid.valid && userValid.valid) )
                    
                }
            )
        } // NavigationView
        
    }
}

#if DEBUG
import KeychainAccess

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        
        KeyItemForm( item: KeyItem( id:"id1", username:"username1", password:Keychain.generatePassword()))
        
        
    }
}
#endif
    
