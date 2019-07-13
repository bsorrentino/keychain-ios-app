//
//  KeyItemDetail.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

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

struct KeyItemDetail : View {
    
    @ObjectBinding var item:KeyItem
    @State var secretInfo:SecretInfo = .hide
    
    var body: some View {
        NavigationView {
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
                    TextFieldAndLabel( label: "Username", value:$item.username )
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
                        Text(SecretInfo.hide.text).tag(SecretInfo.hide)
                        Text(SecretInfo.show.text).tag(SecretInfo.show)
                    }
                    Spacer(minLength: 20)
                    Button( action:{
                        print( "Save" )
                    }, label: {
                        //Image( systemName: "plus" )
                        Text("save")
                    })
                }
            )
        }
        
    }
}

#if DEBUG

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        
        KeyItemDetail(item: KeyItem( id:"id1", username:"username1"))
    }
}
#endif
