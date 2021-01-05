//
//  KeyItemDetail.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 16/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
import FieldValidatorLibrary


struct KeyEntityForm : View {
    @Environment(\.presentationMode)        var presentationMode
    @Environment(\.managedObjectContext)    var managedObjectContext
    @Environment(\.colorScheme)             var colorScheme: ColorScheme
    
    @State          var secretState:SecretState = .hide
    @State private  var pickUsernameFromMail    = false
    @State private  var alertItem:AlertItem?
    
    @ObservedObject var item:KeyItem
    var parentId:Binding<Int>?
    
    private let bg = Color(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, opacity: 0.2)
                    //Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    private let strikeWidth:CGFloat = 0.5
    

    var body: some View {
        NavigationView {
            Form {
                
                if( item.isNew ) {
                    Section(header: Text("Mnemonic"), footer: EmptyView() ) {
                        mnemonicInput()
                    }
                }
                
                Section( header: Text("Credentials")) {
                    usernameInput()
                    PasswordField(value: $item.password, passwordCheck: $item.passwordCheck)
                }
                Section( header: Text("Other")) {
                    GroupField( value:$item.groupPrefix )
                    EmailField( value:$item.mail )
                    UrlField( value:$item.url )
                    NoteField( value:$item.note)
                }
            }
            .navigationBarTitle( Text( item.mnemonic.uppercased()), displayMode: .inline  )
            .navigationBarItems(trailing:
                HStack {
                    // secretStatePicker()
                    // Spacer(minLength: 15)
                    saveButton()
                }
            )
            .onAppear {
                if( !item.isNew ) {
                    
                    if( !item.url.isEmpty ) {
                        
                        if let url = URL(string: item.url), let scheme = url.scheme, scheme == "https"  {
                            
                            let keychain = Keychain(server: item.url, protocolType: .https)
                            if let password = try? keychain.get(item.username) {
                                print( "password for site \(url.absoluteString) and user \(item.username) is \(password)")
                            }
                            else {
                                keychain.getSharedPassword(item.username) { (password, error) -> () in
                                        if password != nil {
                                            // If found password in the Shared Web Credentials,
                                            // then log into the server
                                            // and save the password to the Keychain

                                            print( "password for site \(url.absoluteString) and user \(item.username) is \(String(describing: password))")
                                        } else {
                                            // If not found password either in the Keychain also Shared Web Credentials,
                                            // prompt for username and password

                                            // Log into server

                                            // If the login is successful,
                                            // save the credentials to both the Keychain and the Shared Web Credentials.
                                            print( "password for site \(url.absoluteString) and user \(item.username) not found!\n\(error ?? "")")
                                        }
                                }
                            }
                            
                        }
                    }
                }
                
            }
        } // NavigationView
        
    }
}


//
// MARK: - Show / hide Secrets
// MARK: -
//
enum SecretState: Int, Hashable {
    
    case hide
    case show

    var text:String {
        switch( self ) {
            case .hide: return "***"
            case .show: return "abc"
        }
    }

}

extension KeyEntityForm {
    
    func secretStatePicker() -> some View {
        
        Picker( selection: $secretState, label: EmptyView() ) {
            Image( systemName: "eye.slash").tag(SecretState.hide)
            //Text(SecretInfo.hide.text).tag(SecretInfo.hide)
            Image( systemName: "eye").tag(SecretState.show)
            //Text(SecretInfo.show.text).tag(SecretInfo.show)
        }
        .pickerStyle(SegmentedPickerStyle())

    }
}

//
// MARK: - Controls
// MARK: -
//
extension KeyEntityForm {
    
    
    func saveButton() -> some View {
        
        Button( "save", action: {
            print( "Save\n mnemonic: \(self.item.mnemonic)\n username: \(self.item.username)" )
            
            do {
                try self.item.insert( into: self.managedObjectContext )
                try self.managedObjectContext.save()

                parentId?.wrappedValue += 1 // force view refresh

                if( self.item.isNew ) {
                    self.item.reset()
                }
            }
            catch {
                if( self.item.isNew ) {
                    self.alertItem = makeAlertItem( error:"error inserting new key \(error)" )
                }
                else {
                    self.alertItem = makeAlertItem( error:"error updating new key \(error)")
                }
            }
            
            
            self.presentationMode.wrappedValue.dismiss()
            
            
        })
        .disabled( !item.checkIsValid )
        .alert(item: $alertItem) { item  in makeAlert(item:item) }
    }
    
    
    func mnemonicInput() -> some View  {
        
        VStack(alignment: .leading) {
            TextFieldWithValidator( title: "give me the unique name of key",
                                    value: $item.mnemonic,
                                    checker:$item.mnemonicCheck ) { v in
                
                if( v.isEmpty ) {
                    
                    return "mnemonic cannot be empty"
                }
                
                return nil
            }
            .autocapitalization(.allCharacters)
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
            .overlay( ValidatorMessageInline( message: item.mnemonicCheck.errorMessage )
                ,alignment: .bottom)

        }
            

    }
    
    func usernameInput() -> some View {
        
        HStack{
            ZStack {
                
                TextFieldWithValidator( title:"give me the username ?",
                                        value: $item.username,
                                        checker:$item.usernameCheck ) { v in
                    
                    if( v.isEmpty ) {
                        return "username cannot be empty"
                    }
                    
                    //print( "validate username \(v) - \(self.pickUsernameFromMail)")
                    
                    if( self.pickUsernameFromMail ) {
                        self.item.mail = v
                    }
                    return nil
                }
                .autocapitalization(.none)
                NavigationLink( destination: EmailList( value: $item.username_mail_setter), isActive:$pickUsernameFromMail  ) {
                       EmptyView()
                }
                .hidden()
            }
            Button( action: {
                hideKeyboard()
                self.pickUsernameFromMail = true
                
            }) {
                Image( systemName: "envelope.circle")
                    .resizable().frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor( colorScheme == .dark ? Color.white : Color.black )
            }


        }
        .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
        .overlay(
            ValidatorMessageInline( message:item.usernameCheck.errorMessage ), alignment: .bottom
        )

    }

}

//
// MARK: - Preview
// MARK: -
//

#if DEBUG
import KeychainAccess

struct KeyItemDetail_Previews : PreviewProvider {
    static var previews: some View {
        // @see https://www.hackingwithswift.com/quick-start/swiftui/how-to-preview-your-layout-in-light-and-dark-mode
        
        
        Group {
            KeyEntityForm( item:KeyItem() )
               .environment(\.colorScheme, .light)

            KeyEntityForm( item:KeyItem() )
               .environment(\.colorScheme, .dark)
         }
    }
}
#endif
    
