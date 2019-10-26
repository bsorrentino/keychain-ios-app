//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary

struct EmailForm : View {
    
    @State var mailValid = FieldChecker()
    @State var result:String = ""
    
    var body: some View {
        
       VStack(alignment: .leading) {
            //Text("mail")
            TextFieldWithValidator( title: "insert email", value: $result, checker:$mailValid ) { v in
                   
                   if( v.isEmpty ) {
                       return "mail cannot be empty"
                   }
                   
                   return nil
            }
        }
       .padding(10.0)
    }
}

struct EmailList: View {
    @State private var showModal = false
    
    @Binding var value:String
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest( entity: MailEntity.entity(),
                   sortDescriptors: [ NSSortDescriptor(keyPath: \MailEntity.name, ascending: true)]
    ) var mails:FetchedResults<MailEntity>
    
    
    var body: some View {
        
        NavigationView {
            
            List {
                ForEach( mails, id: \MailEntity.id ) { (mail:MailEntity) in
                    Text( mail.name ?? "unknown")
                }
                .onDelete( perform: delete)
            }
             .navigationBarTitle("email")
             .navigationBarItems(
                 leading: Button( action: add, label: { Text("Add") } ),
                 trailing: EditButton())
         }.sheet(isPresented: $showModal, onDismiss: {
             print(self.showModal)
         }) {
             EmailForm()
         }
    
    }
    
    func delete( at offsets: IndexSet ) {
        if let first = offsets.first {
            let selectMail = mails[ first ]
            
            context.delete(selectMail)
        }
    }
    
    func add() {
        self.showModal = true
    }
}

#if DEBUG
struct EmailList_Previews: PreviewProvider {
    static var previews: some View {
        // https://stackoverflow.com/questions/57700304/previewing-contentview-with-coredata
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        return EmailList( value:.constant("")).environment(\.managedObjectContext, context)
    }
}
#endif

