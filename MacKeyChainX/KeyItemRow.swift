//
//  KeyItemRow.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

func getSharedPassword( withKey key:String ) -> String? {
    
    do {
        let secret = try SharedModule.sharedSecrets.getSecret(forKey: key )
        return secret?.password
    }
    catch {
        logger.warning( """
            WARN: getSharedPassword( withKey: \(key) )
            
            \(error.localizedDescription)
            """ )
        return nil;
    }
}

func label<Content>( _ systemName:String, @ViewBuilder content: () -> Content ) -> some View where Content : View  {
    HStack( alignment: .center ) {
        Image( systemName: systemName )
        content()
    }.font(Font.system(.title2)).padding(5)
}

func doubleLabel<Content>( _ systemName1:String, _ systemName2:String, @ViewBuilder content: () -> Content ) -> some View where Content : View  {
    HStack( alignment: .center ) {
        Image( systemName: systemName1 )
        Image( systemName: systemName2 )
        content()
    }.font(Font.system(.title2)).padding(5)
}

fileprivate struct  passwordText : View {
    
    var value: String
    @State var hidden = true
    
    var body: some View {
        HStack {
            PasswordToggleField( value: .constant(value), hidden: hidden)
                .disabled(true)
                .fixedSize()
                .frame( minWidth: 100,
                        idealWidth: nil,
                        maxWidth: nil,
                        minHeight: nil,
                        idealHeight: nil,
                        maxHeight: nil,
                        alignment: .leading)
            HideToggleButton( hidden: $hidden )
                .background( Color.black )
            CopyToClipboardButton(value: value)
        }
    }
}

fileprivate func usernameText( value:String ) -> some View {
    HStack {
        Text(value)
        CopyToClipboardButton(value: value)
    }
}

func NoteView( item:KeyItem, show:Bool ) -> some View {
    Group {
        if show {
            Spacer()
            Divider()
            Text( "\(item.note)" )
        }
        Spacer()
    }
}

func SecretView( item:KeyItem, show:Bool ) -> some View {
    Group {
        if show {
            label("key.icloud.fill" ) {
                passwordText( value: isInPreviewMode ? "fake password" : item.password)
            }.transition( .asymmetric(insertion: .slide, removal: .opacity))
        }
        else {
            EmptyView()
        }
    }
}


struct KeyItemRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var mcSecretsService:MCSecretsService
    
    var item:KeyItem
    
    @State private var isShowSecret = false
    
    var isShared:Bool {
        if( isInPreviewMode) {
            return false
        }
        // return getSharedPassword( withKey: item.mnemonic ) != nil
        return item.shared
    }
    
    var body: some View {
        //GeometryReader { geometry in
        HStack {
            
            VStack( alignment: .leading ) {
                
                HStack {
                    Text( item.mnemonic )
                        .padding(6)
                        .background( Color.blue)
                        .clipShape(Capsule())
                    
                    Spacer()
                    if( isShared ) {
                        sharedView()
                    }
                    else {
                        notSharedView()
                    }
                    
                }
                .font(Font.system(.title))
                
                Divider()
                
                HStack {
                    VStack( alignment: .leading ) {
                        if let mail = item.mail, !mail.isEmpty {
                            
                            if( mail == item.username ) {
                                doubleLabel( "person.circle.fill", "envelope.fill") {
                                    usernameText( value:item.username)
                                }
                                SecretView( item:item, show:isShowSecret)
                            }
                            else {
                                label("person.circle.fill") {
                                    usernameText(value: item.username)
                                }
                                SecretView( item:item, show:isShowSecret)
                                label("envelope.fill") { Text( mail) }
                            }
                        }
                        else {
                            label("person.circle.fill") {
                                usernameText( value:item.username)
                            }
                            SecretView( item:item, show:isShowSecret)
                        }
                        if let url = item.url, !url.isEmpty {
                            
                            label("link" ) { Text(url) }
                            
                        }
                    }
                    NoteView( item:item, show:isShowSecret )
                }
            }
            .padding()
        }
        .border(Color.gray, width: 1)
        .onDisappear {
            isShowSecret = false
        }
    }
    
}

// Shared Actions Extension
extension KeyItemRow {
    
    func sharedView() -> some View {
        
        Button( action: {
            Task {
                do {
                    if( try await SharedModule.authcService.tryAuthenticate() ) {
                        withAnimation {
                            self.isShowSecret.toggle()
                        }
                    }
                }
                catch( let error ) {
                    logger.error( "\(error.localizedDescription)")
                }
            }
        }) {
            Group {
                if self.isShowSecret {
                    Image( systemName: "eye" ).foregroundColor(.yellow)
                }
                else {
                    Image( systemName: "eye.slash")
                }
            }
        }.buttonStyle(PlainButtonStyle())
        
    }
    
}

// Not Shared Actions Extension
extension KeyItemRow {
    
    func notSharedView() -> some View  {
        Group {
            if !mcSecretsService.connectedPeers.isEmpty {
                Button( action:{
                    Task {
                        do {
                            if( try await SharedModule.authcService.tryAuthenticate() ) {
                                
                                let secret = try await self.mcSecretsService.requestSecret(forKey: item.mnemonic)
                                
                                item.password = secret.password
                                if let note = secret.note {
                                    item.note = note
                                }
                                withAnimation {
                                    self.isShowSecret.toggle()
                                }
                            }
                        }
                        catch( let error ) {
                            logger.error( "\(error.localizedDescription)")
                        }
                    }
                    //                    self.mcSecretsService.requestSecret(forKey: item.mnemonic) { result in
                    //                        switch( result ) {
                    //                        case .success( let secret ):
                    //                            SharedModule.authcService.tryAuthenticate { result in
                    //                                if case .success(true) = result {
                    //                                    item.password = secret.password
                    //                                    if let note = secret.note {
                    //                                        item.note = note
                    //                                    }
                    //                                    withAnimation {
                    //                                        self.isShowSecret.toggle()
                    //                                    }
                    //                                }
                    //                            }
                    //                        case .failure( let error ):
                    //                            logger.error( "\(error.localizedDescription)")
                    //                        }
                    //                    }
                }) {
                    Image( systemName: "icloud.slash")
                        .foregroundColor(Color.yellow)
                }
                .buttonStyle(PlainButtonStyle())
            }
            else {
                Image( systemName: "icloud.slash")
                    .foregroundColor(Color.red)
            }
        }
    }
}


struct KeyItemRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let item = { () -> KeyItem in
            
            let key = KeyEntity( entity:KeyEntity.entity(), insertInto: context )
            
            key.mnemonic = "MNEMONIC"
            key.username = "bartolomeo.sorrentino@soulsoftware.it"
            key.mail = "bartolomeo.sorrentino@soulsoftware.it"
            key.url = "http://usernamesite.com"
            
            
            return KeyItem( entity:key )
        }
        return KeyItemRow( item:item() )
    }
}
