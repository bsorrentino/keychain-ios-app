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


class FieldValidator<T> : BindableObject {
    typealias Validator = (T) -> String?
    
    let didChange = PassthroughSubject<Void, Never>()
    
    var value:T {
        willSet {
            self.doValidate( newValue )
            bindValue.value = newValue
        }
    }
    var errorMessage:String?
    
    let validator:Validator
    
    var bindValue:Binding<T>
    
    init( _ value:Binding<T>, validator:@escaping Validator  ) {
        self.validator = validator
        self.value = value.value
        self.bindValue = value
    }
    
    func doValidate( _ newValue:T? = nil ) -> Void {
        if let v = newValue {
            self.errorMessage = self.validator( v )
        }
        else {
            self.errorMessage = self.validator( self.value )
        }
        self.didChange.send()
    }
}


struct TextFieldAndLabelWithValidator : View {
    typealias Validator = (String) -> String?
    
    var label:String;
    var title:String?
    
    @ObjectBinding var field:FieldValidator<String>
    
    init( label:String, value:Binding<String>, validator:@escaping Validator ) {
        self.label = label;
        self.title = label;
        self.field = FieldValidator<String>(value, validator:validator )
    }
    init( label:String, title:String, value:Binding<String>, validator:@escaping Validator ) {
        self.label = label;
        self.title = title;
        self.field = FieldValidator<String>(value, validator:validator )
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text( label )
            TextField( title ?? label, text: $field.value )
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0), cornerRadius: 5.0)
                .border( field.errorMessage != nil ? Color.red : Color.clear )
        }.onAppear {
            self.field.doValidate()
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

    var body: some View {
        //NavigationView {
            Form {
                
                if( item.state == KeyItem.State.new ) {
                    Section {
                        
                        TextFieldAndLabelWithValidator( label: "mnemonic",value: $item.id ) { v in
                            
                            if( v.isEmpty ) {
                                return "mnemonic cannot be empty"
                            }
                            
                            return nil
                        }                    }

                }

                Section {
                    TextFieldAndLabelWithValidator( label: "username",value: $item.username ) { v in
                        
                        if( v.isEmpty ) {
                            return "username cannot be empty"
                        }
                        
                        return nil
                        }
                    
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
                        print( "Save \(self.item.username)" )
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
