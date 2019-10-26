//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



struct EmailList: View {
    @Binding var value:String
    
    @FetchRequest( entity: MailEntity.entity(),
                   sortDescriptors: [ NSSortDescriptor(keyPath: \MailEntity.name, ascending: true)]
    ) var mails:FetchedResults<MailEntity>
    
    
    var body: some View {
        
        List(mails, id: \MailEntity.id) { (mail:MailEntity) in
            Text( mail.name ?? "unknown")
        }
        .padding(.all)
        .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
    
    }
}

#if DEBUG
struct EmailList_Previews: PreviewProvider {
    static var previews: some View {
        EmailList( value:.constant(""))
    }
}
#endif

