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

struct TextFieldAndLabel : View {
    
    var label:String;
    var title:String?
    
    @Binding var value:String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text( label )
            TextField( title ?? label, text: $value )
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0), cornerRadius: 5.0)

            
        }
        
    }
}

struct TextFieldAndLabel2 : View {
    
    var label:String;
    var title:String?
    
    @ObjectBinding var field:FieldChecker<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text( label )
            TextField( title ?? label, text: $field.value )
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0), cornerRadius: 5.0)
                .border( field.errorMessage != nil ? Color.red : Color.clear )
            
        }
        
    }
}

enum SecretInfo: Int, Hashable {
    
    case hide
    case show
}

struct SecretFieldAndLabel : View {
    
    var label:String;
    var title:String?
    
    @Binding var value:String
    @Binding var secretInfo:SecretInfo

    var body: some View {
        VStack(alignment: .leading) {
            Text( label )
            Group {
                if( secretInfo == .hide ) {
                    SecureField( "password", text:$value)
                }
                else {
                    TextField( "password", text:$value)
                }
            }
            .padding(.all)
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0), cornerRadius: 5.0)
            
        }
        
    }
}

class FieldChecker<T> : BindableObject {
    typealias Validator = (T ) -> String?
    
    let didChange = PassthroughSubject<Void, Never>()
    
    var value:T {
        didSet {
            self.errorMessage = self.validate( self.value )
            self.didChange.send()
        }
    }
    var errorMessage:String?;
    
    let validate:Validator
    
    init( _ value:T, validator:@escaping Validator  ) {
        self.validate = validator
        self.value = value
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
    
    @ObjectBinding var item:KeyItem
    @State var secretInfo:SecretInfo = .hide

    var username = FieldChecker<String>("") { v in
        
        "error"
    }

    var body: some View {
        //NavigationView {
            Form {
                /*
                Section {
                    
                    VStack(alignment: .leading) {
                        Text( "MNEMONIC" )
                        Text( item.id )
                        
                    }
                }
                */
                Section {
                    TextFieldAndLabel2( label: "Username", field: username )
                    SecretFieldAndLabel( label: "Password", value:$item.password, secretInfo:$secretInfo )
                    
                }
                Section {
                    TextFieldAndLabel( label: "eMail", value:$item.email )
                    PresentationLink( destination: KeyItemNote( value:$item.note ) ){
                        Text("Note")
                    }
                }

            }
            .navigationBarTitle( Text("\(item.id.uppercased())"), displayMode: .inline  )
            .navigationBarItems(trailing:
                HStack {
                    SegmentedControl( selection: $secretInfo ) {
                        Image( systemName: "eye.slash").tag(SecretInfo.hide)
                        //Text(SecretInfo.hide.text).tag(SecretInfo.hide)
                        Image( systemName: "eye").tag(SecretInfo.show)
                        //Text(SecretInfo.show.text).tag(SecretInfo.show)
                    }
                    Spacer(minLength: 15)
                    Button( action:{
                        print( "Save" )
                    }, label: {
                        //Image( systemName: "plus" )
                        Text("save")
                    })
                }
            )
        //}
        
    }
}

#if DEBUG

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        
        KeyItemForm(item: KeyItem( id:"id1", username:"username1"))
        
        
    }
}
#endif
