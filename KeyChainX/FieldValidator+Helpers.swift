//
//  FieldValidator+Overlay.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 17/08/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary


struct ValidatorMessageModifier: ViewModifier {
    
    var message:String?
    
    var msg: some View {
        HStack {
            Text( message ?? "")
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
            
            if message != nil  {
                Image( systemName: "exclamationmark.triangle")
                    .foregroundColor(Color.red)
                    .font(.footnote)
            }
        }
    }

    func body(content: Content) -> some View {
        return content.overlay( msg, alignment: .bottom )
    }
}

struct ValidatorMessageInline: View {
    
    var message:String?
    
    var body: some View {
        HStack {
            Text( message ?? "")
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
            
            if message != nil  {
                Image( systemName: "exclamationmark.triangle")
                    .foregroundColor(Color.red)
                    .font(.footnote)
            }
            
        }
    }
}


extension FieldChecker2 {
        var errorMessageOrNilAtBeginning:String?  {
            self.isFirstCheck ? nil : errorMessage
        }

}

extension FieldChecker {
    var padding:EdgeInsets {
        ( !self.valid && !self.isFirstCheck ) ? .init(top:5, leading: 0, bottom: 25, trailing: 0) : .init()
    }
    
}
