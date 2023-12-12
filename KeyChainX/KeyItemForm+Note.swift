//
//  Note.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



struct NoteField : View {
    
    var value:String

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
        
        HStack(alignment: .center) {
            Image( systemName: "doc.circle").resizable().frame(width: 20, height: 20, alignment: .leading)
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


struct KeyItemNote : View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var field:String
    
    var body: some View {

        VStack {
            Divider()
            //        NoteTextView( text: self.$value )
            NoteView( text: self.$field )
                .navigationBarTitle( Text("Note"), displayMode: .inline  )
                .navigationBarItems(trailing: Button("done") {
                    self.presentationMode.wrappedValue.dismiss()
                })
            Divider()
        }

    }
}

#Preview {
    KeyItemNote( field: .constant("TEST") )
}

