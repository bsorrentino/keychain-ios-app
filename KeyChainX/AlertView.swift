//
//  AlertView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 20/08/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct AlertItem : Identifiable {
    var id = UUID()
    var title:String
    var message: String
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?
    
}

func  makeAlert( item alertItem:AlertItem ) -> Alert {
    
      guard let primary = alertItem.primaryButton else {
           return Alert( title: Text(alertItem.title), message: Text(alertItem.message) )
       }
       
       if let secondary = alertItem.secondaryButton {
           return Alert( title: Text(alertItem.title), message: Text(alertItem.message), primaryButton: primary, secondaryButton: secondary )
       }
       
       return Alert( title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: primary )
}
