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
import Shared


struct KeyEntityForm : View {
    @Environment(\.presentationMode)        var presentationMode
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme)             var colorScheme: ColorScheme
    
    @State          var secretState:SecretState = .hide
    @State private  var pickUsernameFromMail    = false
    @State private  var alertItem:AlertItem?

    @ObservedObject var item:KeyItem
    
    private let bg = Color(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, opacity: 0.2)
                    //Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    private let strikeWidth:CGFloat = 0.5
    
    @StateObject var passwordCheck = FieldChecker2<String>()
    @StateObject var mnemonicCheck = FieldChecker2<String>()
    @StateObject var usernameCheck = FieldChecker2<String>()

    // https://forums.swift.org/t/state-vars-didset-fix-or-prohibition/53161/9
//    @State var username_mail_setter: String = "" {
//        didSet {
//            item.username = usernameCheck.doValidate(value: username_mail_setter)
//            item.mail = username_mail_setter
//        }
//    }
    var  username_mail_setter_binding: Binding<String>  {
        Binding(
            get: { item.username },
            set: {
                item.username = usernameCheck.doValidate(value: $0)
                item.mail = $0
            }
        )
    }
    
    var checkIsValid:Bool {
        return  mnemonicCheck.valid &&
                usernameCheck.valid &&
                passwordCheck.valid
    }

    var body: some View {
        NavigationView {
            Form {
                
                if( item.isNew ) {
                    Section(header: Text("Mnemonic"), footer: EmptyView() ) {
                        mnemonicInput()
                    }
                }
                Section( header: HStack {
                        Text("Credentials")
                        Divider()
                        Spacer()
                        Text("shared")
                    Toggle( "shared", isOn: $item.shared ).labelsHidden()
                })
                {
                    usernameInput()
                    PasswordField(value: $item.password, passwordCheck: passwordCheck)
                    
                }
                Section( header: Text("Other")) {
                    GroupField( value:$item.groupPrefix )
                    EmailField( value:$item.mail )
                    UrlField( value:$item.url )
                    NoteField( value:$item.note)
                }
            }
            .navigationBarTitle( Text( item.mnemonic.uppercased()), displayMode: .inline  )
            .navigationBarItems(leading:
                starButton()
            )
            .navigationBarItems(trailing:
                saveButton()
            )
            .onAppear {
                if( !item.isNew ) {
                    
                    if( !item.url.isEmpty ) {
                        
                        SharedModule.getWebSharedPassword(forUsername: item.username, fromUrl: item.url) { result in
                            
                            switch result {
                            case .success(let password):
                                if password != nil {
                                    // If found password in the Shared Web Credentials,
                                    // then log into the server
                                    // and save the password to the Keychain

                                    logger.trace( "password for site \(item.url) and user \(item.username) is \(String(describing: password),privacy: .private )")
                                } else {
                                    // If not found password either in the Keychain also Shared Web Credentials,
                                    // prompt for username and password

                                    // Log into server

                                    // If the login is successful,
                                    // save the credentials to both the Keychain and the Shared Web Credentials.
                                    logger.trace( "password for site \(item.url) and user \(item.username) not found!")
                                }

                            case .failure(let error):
                                logger.warning( "WARN: getWebSharedPassword()\n\(error.localizedDescription)")
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
// MARK: - Input Controls
// MARK: -
//
extension KeyEntityForm {
    
    func mnemonicInput() -> some View  {
        
        TextField( "give me the unique name of key",
                   text: $item.mnemonic.onValidate( checker: mnemonicCheck ) { v  in

            if( v.isEmpty ) {
                return "mnemonic cannot be empty"
            }
            return nil
        })
        .autocapitalization(.allCharacters)
        .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
        .modifier(ValidatorMessageModifier( message: mnemonicCheck.errorMessage ))
            
    }
    
    func usernameInput() -> some View {
        
        HStack{
            ZStack {
                TextField( "give me the username",
                           text: $item.username.onValidate( checker: usernameCheck ) { v in
                    
                    if( v.isEmpty ) {
                        return "username cannot be empty"
                    }
                    //logger.trace( "validate username \(v) - \(self.pickUsernameFromMail)")
                    if( self.pickUsernameFromMail ) {
                        self.item.mail = v
                    }
                    return nil
                })
                .autocapitalization(.none)
                NavigationLink( destination: EmailList( value: username_mail_setter_binding ), isActive:$pickUsernameFromMail  ) {
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
            CopyToClipboardButton( value:item.username )

        }
        .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
        .modifier(ValidatorMessageModifier( message:usernameCheck.errorMessage ))

    }

}

//
// MARK: - Toolbar
// MARK: -
//
extension KeyEntityForm {

    func starButton() -> some View {
        Button( action: {
            item.preferred.toggle()
        },
        label: {
            
            if( item.preferred ) {
                Image( systemName: "star.fill")
            }
            else {
                Image( systemName: "star")
            }
        })
    }
    
    func saveButton() -> some View {
        
        Button( "save", action: {
            logger.trace( "Save\n mnemonic: \(self.item.mnemonic)\n username: \(self.item.username)" )
            
            _ = saveItem().sink(
                receiveCompletion: {
                    switch $0  {
                    case .failure(let error):
                        
                        let op = (self.item.isNew) ? "inserting": "updating"
                        self.alertItem = makeAlertItem( error:"error \(op) new key \(error)",
                                                        primaryButton: .destructive( Text("Abort")) {
                                                            self.presentationMode.wrappedValue.dismiss()
                                                        },
                                                        secondaryButton: .cancel() )
                    case .finished:

                        if( self.item.isNew ) {
                            self.item.reset()
                        }
                        
                        self.presentationMode.wrappedValue.dismiss()

                    }
                },
                receiveValue: {}
            )
        })
        .disabled( !checkIsValid )
        .alert(item: $alertItem) { item  in makeAlert(item:item) }
    }
    
    

    fileprivate func saveItem() -> Future<Void,Error> {
        
        return Future { promise in
            
            do {
                try self.item.insertOrUpdate( into: self.context )

                promise(.success(()))
            }
            catch {
                logger.error("""
                    ERROR: saving Item
                    
                    \(error.localizedDescription)
                    """)
                promise(.failure(error))
            }

        }
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
    
