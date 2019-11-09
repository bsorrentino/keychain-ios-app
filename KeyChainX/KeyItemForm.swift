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



struct KeyEntityForm : View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var key:KeyEntity
    
    @State var secretInfo:SecretInfo = .hide
    
    @State var userValid        = FieldChecker()
    @State var mnemonicValid    = FieldChecker()
    @State var passwordValid    = FieldChecker()

    init( key:KeyEntity ) {
        self.key = key
    }
    
    func mnemonicInput() -> some View  {
        
        VStack(alignment: .leading) {
            HStack {
                Text("mnemonic")
                if( !mnemonicValid.valid  ) {
                    Spacer()
                    Text( mnemonicValid.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            TextFieldWithValidator( value: $key.mnemonic, checker:$mnemonicValid ) { v in
                
                if( v.isEmpty ) {
                    return "mnemonic cannot be empty"
                }
                
                return nil
            }
            .padding(.all)
            .border( mnemonicValid.valid ? Color.clear : Color.red , width: 0.5)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.allCharacters)
    
        }
            

    }
    
    func userInput() -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("username")
                if( !userValid.valid  ) {
                    Spacer()
                    Text( userValid.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            TextFieldWithValidator( value: $key.username, checker:$userValid ) { v in
                
                if( v.isEmpty ) {
                    return "username cannot be empty"
                }
                
                return nil
            }
            .padding(.all)
            .border( userValid.valid ? Color.clear : Color.red , width: 0.5)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            
        }


    }

    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("Password")
                if( !passwordValid.valid  ) {
                    Spacer()
                    Text( passwordValid.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }

            }
            PasswordToggleField( value:$key.password, checker:$passwordValid, secretInfo:$secretInfo ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    return nil
            }
            .padding(.all)
            .border( passwordValid.valid ? Color.clear : Color.red , width: 0.5)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            

        }

    }

    
    var body: some View {
        NavigationView {
            Form {
                

                if( key.isInserted ) {
                    Section {
                        
                        mnemonicInput()
                        
                    }

                }

                Section {
                    
                    userInput()
                    
                    passwordInput()
                                        
                }
                
                Section {
                    
                    EmailField( value:$key.mail )
                    
                    NoteField( value:$key.note)
                    
                }
            }
            .navigationBarTitle( Text("\(key.mnemonic.uppercased())"), displayMode: .inline  )
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
                        print( "Save\n mnemonic: \(self.key.mnemonic)\n username: \(self.key.username)" )
                        
                        //self.managedObjectContext.insert(self.item)

                        do {
                            try self.managedObjectContext.save()
                        }
                        catch {
                            print( "error inserting new key \(error)" )
                        }
                        
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
        
        KeyEntityForm( key: KeyEntity() )
        
        
    }
}
#endif
    
