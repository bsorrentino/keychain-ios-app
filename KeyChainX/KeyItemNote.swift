//
//  Note.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemNote : View {
    @Environment(\.isPresented) private var isPresented
    
    @Binding var value:String
    
    var body: some View {
        NavigationView {
                VStack {
                    GeometryReader { geometry in
                        TextField( "note", text: self.$value )
                            .frame( width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                            .background( Color.yellow)
                            .lineLimit(30)
                    }
                    Button("OK") {
                        self.isPresented?.value = false
                    }
            }.navigationBarTitle( Text("Note"), displayMode: .inline  )
        }

    }
}

#if DEBUG
struct Note_Previews : PreviewProvider {
    static var previews: some View {
        KeyItemNote( value: .constant("TEST") )
    }
}
#endif
