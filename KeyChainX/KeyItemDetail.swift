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
    var placeholder:String?
    
    @Binding var value:String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text( label )
            TextField( $value, placeholder: Text("placeholder") )
            
        }
        
    }
}


struct KeyItemDetail : View {
    
    @ObjectBinding var item:KeyItem
    
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
                    TextFieldAndLabel( label: "Username", value:$item.username )
                    TextFieldAndLabel( label: "password", value:$item.password )
                }
                Section {
                    TextFieldAndLabel( label: "eMail", value:$item.email )
                    TextFieldAndLabel( label: "Note", value:$item.note )
                }

            }.navigationBarTitle( Text("\(item.id.uppercased())"), displayMode: .inline  )
        //}
    }
}

#if DEBUG

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        
        KeyItemDetail(item: KeyItem( id:"id1", username:"username1"))
    }
}
#endif
