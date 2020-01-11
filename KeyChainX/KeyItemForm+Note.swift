//
//  Note.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



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
            .padding(EdgeInsets( top: 20, leading: 0, bottom: 20, trailing: 0))
        }
    }

    
}


struct KeyItemNote : View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var value:String
    
    var body: some View {
        
                VStack {
                    GeometryReader { geometry in
                        NoteTextView( text: self.$value )
                            .frame( width: geometry.size.width,
                                    height: geometry.size.height,
                                    alignment: .topLeading)
                    }
                    
                    }
                    .navigationBarTitle( Text("Note"), displayMode: .inline  )
                    .navigationBarItems(trailing: Button("done") {
                        self.presentationMode.wrappedValue.dismiss()
                    })

    }
}

#if DEBUG
struct Note_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyItemNote( value: .constant("TEST") )
        }
    }
}
#endif
