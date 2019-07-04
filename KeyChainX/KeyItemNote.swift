//
//  Note.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemNote : View {
    
    @Binding var value:String
    
    var body: some View {
        TextField( $value )
    }
}

#if DEBUG
struct Note_Previews : PreviewProvider {
    static var previews: some View {
        KeyItemNote( value: .constant("") )
    }
}
#endif
