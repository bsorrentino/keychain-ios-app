//
//  EmailList.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 26/10/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import SwiftData
import Combine
import FieldValidatorLibrary
import Shared

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
    
    var value:String
    
    var body: some View {
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


struct EmailList: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var field:String
    
    @Environment(\.modelContext) var context
    
    @Query( sort: \AttributeInfo.value, animation: .default)
    var mails: [AttributeInfo]
    
    @StateObject var mailValid = FieldChecker2<String>()
    @State var newMail:String = ""
    
    var validateChecks = 0
    
    var body: some View {
        
        List {
            Section(header: Text("New Mail")) {
                
                HStack {
                    TextField( "insert email", text: $newMail.onValidate(checker: mailValid ) { v in
                        
                        if( v.isEmpty ) {
                            return "mail cannot be empty !"
                        }
                        if( !v.isEmail() ) {
                            return "mail is not in correct format"
                        }
                        
                        return nil
                    })
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .font(.body)
                    .padding( .bottom, 25  )
                    .modifier( ValidatorMessageModifier( message: mailValid.errorMessageOrNilAtBeginning ) )
                    addButton()
                }
                
            }
            .font( .headline )
            
            
            Section(header: Text("Mails")) {
                //                    ForEach( mails, id: \MailEntity.value ) { (mail:MailEntity) in
                ForEach( mails, id: \AttributeInfo.value ) { (mail:AttributeInfo) in
                    Text( mail.value ?? "unknown")
                        .font( .body ).onTapGesture(perform: {
                            self.field = mail.value ?? "unknown"
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    
                }
                .onDelete( perform: delete)
                
                
            }
            .font( .headline )
        }
        .navigationBarTitle( Text("email"), displayMode: .inline )
        .navigationBarItems( trailing: EditButton() )
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
    
    
    
    
}


extension EmailList {
    
    func delete( at offsets: IndexSet ) {
        if let first = offsets.first {
            let selectMail = mails[ first ]
            
            context.delete(selectMail)
        }
    }
    
    func insert() {
        
        let mail = AttributeInfo( value: self.newMail )
        
        self.context.insert(mail)
        
        self.newMail = mailValid.doValidate(value: "")
    }
    
}

#Preview {
    
    let container = UIApplication.shared.modelContainer
    
    return EmailList( field:.constant(""))
        .modelContainer(container)
    
}

