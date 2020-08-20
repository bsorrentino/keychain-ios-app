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
    var title:Text
    var message: Text
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?
}

func makeAlertItem( error:String, primaryButton: Alert.Button? = nil, secondaryButton: Alert.Button? = nil) -> AlertItem  {
    return AlertItem( title:Text("Error").foregroundColor(Color.red), message:Text(error), primaryButton:primaryButton, secondaryButton: secondaryButton )
}

func makeAlert( item alertItem:AlertItem ) -> Alert {
    
    guard let primary = alertItem.primaryButton else {
        return Alert( title: alertItem.title, message: alertItem.message )
    }

    if let secondary = alertItem.secondaryButton {
       return Alert( title: alertItem.title, message: alertItem.message, primaryButton: primary, secondaryButton: secondary )
    }

    return Alert( title: alertItem.title, message: alertItem.message, dismissButton: primary )
}


