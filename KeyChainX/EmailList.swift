//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary


let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
let __emailRegex = "\(__firstpart)@\(__serverpart)[A-Za-z]{2,8}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}

struct EmailForm : View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var context
    @State var mailValid = FieldChecker()
    @State var result:String = ""
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                TextFieldWithValidator( title: "insert email", value: $result, checker:$mailValid ) { v in
                       
                        if( v.isEmpty ) {
                           return "mail cannot be empty !"
                        }
                        if( !v.isEmail() ) {
                            return "mail is not in correct format !"
                        }
                       
                       return nil
                }
                .autocapitalization(.none)
                .padding( 10 )
                Button( "Confirm", action: {
                    self.insert()
                    self.presentation.wrappedValue.dismiss()
                })
                .padding(  50 )
                .disabled( !mailValid.valid )
            }
            .navigationBarTitle("Mail Form")
                .navigationBarItems(leading:
                    
                    Image(systemName: "envelope")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30.0, height: 30.0, alignment: .leading)

                )
        }
    }
    
    func insert() {
        let mail = MailEntity(context: self.context)
        mail.id = self.result
        mail.name = self.result
        
        self.context.insert(mail)
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
            .navigationBarTitle( Text("email"), displayMode: .inline )
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

