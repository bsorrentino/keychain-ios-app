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
    
    @State var labelValue = "test"
    
    var body: some View {
        NavigationView {
            Form {
                TextFieldAndLabel( label: "Label", value:$labelValue )
                
            }
        }
    }
}

#if DEBUG

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        KeyItemDetail()
    }
}
#endif
