//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI


let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
let __emailRegex = "\(__firstpart)@\(__serverpart)[A-Za-z]{2,8}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}

struct EmailList: View {

    @Environment(\.presentationMode) var presentationMode

    @Binding var value:String
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest( fetchRequest:MailEntity.fetchAllMail() )
    var mails:FetchedResults<MailEntity>
    
    @State var mailValid = FieldChecker()
    @State var newMail:String = ""

    var body: some View {
        
        NavigationView {
            
            List {
                Section(header: Text("New Mail")) {
                    HStack {
                        TextFieldWithValidator( title: "insert email", value: $newMail, checker:$mailValid ) { v in
                               
                                if( v.isEmpty ) {
                                   return "mail cannot be empty !"
                                }
                                if( !v.isEmail() ) {
                                    return "mail is not in correct format !"
                                }
                               
                               return nil
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.body)
                        
                        addButton()
                    }
                    
                }.font( .headline )
                
                Section(header: Text("Mails")) {
                    ForEach( mails, id: \MailEntity.id ) { (mail:MailEntity) in
                        Text( mail.name ?? "unknown")
                            .font( .body ).onTapGesture(perform: {
                                self.value = mail.name ?? "unknown"
                                self.presentationMode.wrappedValue.dismiss()
                            })
                        
                    }
                    .onDelete( perform: delete)
                

                }
                .font( .headline )
            }
            .navigationBarTitle( Text("email"), displayMode: .inline )
            .navigationBarItems(
                 trailing: EditButton())
         }
    
    }
    
    func addButton() -> some View {
        Button( action: {
              self.insert()
          }) {
              Image( systemName: "plus.circle.fill" )
                .foregroundColor( mailValid.valid ? .green : .accentColor)
                  .imageScale(.large)
          }
          .disabled( !mailValid.valid )

     }

    func insert() {
        let mail = MailEntity(context: self.context)
        mail.id = self.newMail
        mail.name = self.newMail
        
        do {
            try self.context.save()
        }
        catch {
            print( "error inserting new mail \(error)" )
        }
        
        self.newMail = ""
    }

    func delete( at offsets: IndexSet ) {
        if let first = offsets.first {
            let selectMail = mails[ first ]
            
            context.delete(selectMail)

            do {
                try self.context.save()
            }
            catch {
                print( "error deleting new mail \(error)" )
            }
        }
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

