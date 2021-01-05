//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
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

struct EmailField : View {
    
    @Binding var value:String

    var body: some View {
        NavigationLink( destination: EmailList( value: $value) ) {
            HStack {
                Image( systemName: "envelope.circle")
                    .resizable().frame(width: 20, height: 20, alignment: .leading)
                if( value.isEmpty ) {
                    Text( "tap to choose email" )
                        .foregroundColor(.gray)
                        .italic()
                }
                else {
                    Text(value )
                }
            }
            .padding(EdgeInsets( top: 20, leading: 0, bottom: 20, trailing: 0))
        }
    }

    
}


struct EmailList: View {

    typealias MailFieldWithValidator = TextFieldWithValidator
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var value:String
    @Environment(\.managedObjectContext) var context
    
    //@FetchRequest( fetchRequest:MailEntity.fetchAllMail() )
    @FetchRequest( fetchRequest:MailEntity.fetchRequest())
    var mails:FetchedResults<MailEntity>
    
    @State var mailValid = FieldChecker()
    @State var newMail:String = ""

    var validateChecks = 0
    
    var body: some View {
        
        //NavigationView {
            
            List {
                Section(header: Text("New Mail")) {
                    
                    HStack {
                        MailFieldWithValidator( title: "insert email", value: $newMail, checker:$mailValid ) { v in
                            
                                if( v.isEmpty ) {
                                   return "mail cannot be empty !"
                                }
                                if( !v.isEmail() ) {
                                    return "mail is not in correct format"
                                }
                               
                               return nil
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .font(.body)
                        .padding( mailValid.padding )
                        .overlay(
                            ValidatorMessageInline( message:mailValid.errorMessageOrNilAtBeginning ), alignment: .bottom
                        )

                        addButton()
                    }
                    
                }
                .font( .headline )
                
                
                Section(header: Text("Mails")) {
                    ForEach( mails, id: \MailEntity.value ) { (mail:MailEntity) in
                        Text( mail.value ?? "unknown")
                            .font( .body ).onTapGesture(perform: {
                                self.value = mail.value ?? "unknown"
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
         //}
    
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
        mail.value = self.newMail
        
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

