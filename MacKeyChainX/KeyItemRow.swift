//
//  KeyItemRow.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

func isInPreviewMode() -> Bool {
    (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil)
}

func getSharedPassword( withKey key:String ) -> String? {
    
    do {
        let secret = try Shared.sharedSecrets.getSecret(forKey: key )
        return secret?.password
    }
    catch {
        print( "WARN: getSharedPassword( withKey: )\n\(error)" )
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

func SecretView( item:KeyItem, show:Bool ) -> some View {
    Group {
        if show {
            label("key.icloud.fill" ) {
                Text(item.password)
            }.transition( .asymmetric(insertion: .slide, removal: .opacity))
        }
        else {
            EmptyView()
        }
    }
}

struct KeyItemRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var item:KeyItem
    
    @State private var isShowSecret = false
    
    var isShared:Bool {
        if( isInPreviewMode() ) {
            return true
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
                        Button( action:{
                            Authentication.shared.tryAuthenticate { result in
                                if case .success(true) = result {
                                    withAnimation {
                                        self.isShowSecret.toggle()
                                    }
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
                    else {
                        Image( systemName: "icloud.slash")
                            .foregroundColor(Color.red)
                    }
                    
                }
                .font(Font.system(.title))
                
                Divider()
                
                if let mail = item.mail, !mail.isEmpty {
                    
                    if( mail == item.username ) {
                        doubleLabel( "person.circle.fill", "envelope.fill") {
                            Text(item.username)
                        }
                        SecretView( item:item, show:isShowSecret)
                    }
                    else {
                        label("person.circle.fill") { Text(item.username) }
                        SecretView( item:item, show:isShowSecret)
                        label("envelope.fill") { Text( mail) }
                    }
                }
                else {
                    label("person.circle.fill") { Text(item.username) }
                }
                if let url = item.url, !url.isEmpty {
                
                    label("link" ) { Text(url) }

                }
            }
            .padding()
        }.border(Color.gray, width: 1)
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
