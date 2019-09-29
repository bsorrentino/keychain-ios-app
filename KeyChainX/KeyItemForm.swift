//
//  KeyItemDetail.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine

class StringFormatter : Formatter {
    
}

class Field<T> : ObservableObject where T : Hashable  {
    
}

class FieldValidator<T> : ObservableObject where T : Hashable {
    typealias Validator = (T) -> String?
    
    @Binding private var bindValue:T
    @Binding private var valid:Bool
    
    @Published var value:T
    {
        willSet {
            self.doValidate(newValue)
        }
        didSet {
            self.bindValue = self.value
        }
    }
    private let validator:Validator
    
    var isValid:Bool {
        return self.valid
    }
    
    var errorMessage:String? {
        return self.validator( self.value )
    }
    
    init( _ value:Binding<T>, valid:Binding<Bool>, validator:@escaping Validator  ) {
        self.validator = validator
        self._bindValue = value
        self.value = value.wrappedValue
        self._valid = valid
    }
    
    func doValidate( _ newValue:T? = nil ) -> Void {
                
        let m =
            (newValue != nil) ?
            self.validator( newValue! ) :
            self.validator( self.value )
        
        self.valid =  m == nil
    }
}


// MARK:  FORM FIELD

struct TextFieldWithValidator : View {
    typealias Validator = (String) -> String?
    
    var title:String?
    
    @ObservedObject var field:FieldValidator<String>
    
    init( title:String = "", value:Binding<String>, valid:Binding<Bool>, validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator<String>(value, valid:valid, validator:validator )
        
    }

    var body: some View {
        VStack {
            TextField( title ?? "", text: $field.value )
                .padding(.all)
                .border( field.isValid ? Color.clear : Color.red )
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                //.cornerRadius(5.0)
                .onAppear {
                    self.field.doValidate()
                }
                if( !field.isValid  ) {
                    Text( field.errorMessage ?? "unknown" )
                }
        }
    }
}

struct EmailField : View {
    
    @Binding var value:String
    
    var mails:Array<String> = [
    
            "bartolomeo.sorrentino@gmail.com         ",
            "bartolomeo.sorrentino@soulsoftware.it   "
    
    ]

    var body: some View {
        
        Picker( "", selection: $value ) {
            ForEach(0 ..< mails.count) {
                Text(self.mails[$0]).tag(self.mails[$0])
            }
        }
        .padding(.all)
        .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
    
    }

}


enum SecretInfo: Int, Hashable {
    
    case hide
    case show
}


struct PasswordField : View {
    typealias Validator = (String) -> String?
    
    @Binding var secretInfo:SecretInfo
    
    @ObservedObject var field:FieldValidator<String>
    
    init( value:Binding<String>, valid:Binding<Bool>, secretInfo:Binding<SecretInfo>, validator:@escaping Validator ) {
        self.field = FieldValidator<String>(value, valid:valid, validator:validator )
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
            .padding(.all)
            .border( field.isValid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            //.cornerRadius(5.0)
            if( !field.isValid  ) {
                Text( field.errorMessage ?? "unknown" )
            }

        }
        .onAppear { self.field.doValidate() }

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


struct KeyItemForm : View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var keys:ApplicationKeys;

    @ObservedObject var item:KeyItem
    
    @State var secretInfo:SecretInfo = .hide
    @State var showNote = false
    
    @State var userValid:Bool = true
    @State var mnemonicValid:Bool = true
    @State var passwordValid:Bool = false

    var body: some View {
        //NavigationView {
            Form {
                

                if( item.state == KeyItem.State.new ) {
                    Section {
                        
                        VStack(alignment: .leading) {
                            Text("mnemonic")
                            TextFieldWithValidator( value: $item.id, valid:$mnemonicValid ) { v in
                                
                                if( v.isEmpty ) {
                                    return "mnemonic cannot be empty"
                                }
                                
                                return nil
                            }
                            .autocapitalization(.allCharacters)
                        }
                    }

                }

                Section {
                    
                    VStack(alignment: .leading) {
                        Text("username")
                        TextFieldWithValidator( value: $item.username, valid:$userValid ) { v in
                            
                            if( v.isEmpty ) {
                                return "username cannot be empty"
                            }
                            
                            return nil
                        }
                        .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Password")
                        PasswordField( value:$item.password, valid:$passwordValid, secretInfo:$secretInfo ) { v in
                                if( v.isEmpty ) {
                                    return "password cannot be empty"
                                }
                                return nil
                        }
                        .autocapitalization(.none)
                    }
                    
                }
                Section {
                    VStack(alignment: .leading ){
                        Text("email")
                        EmailField( value:$item.email )
                    }
                    
                    Button(action: {
                        self.showNote.toggle()
                    }) {
                        Text("Note")
                    }

                    

                }.sheet( isPresented: $showNote ) { () -> KeyItemNote in
                    
                    return KeyItemNote( value:self.$item.note )
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
                    .disabled( !(mnemonicValid && userValid) )
                    
                }
            )
        //}
        
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
