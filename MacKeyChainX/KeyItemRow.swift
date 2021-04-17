//
//  KeyItemRow.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemRow: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var key:KeyEntity
    
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

    var isShared:Bool {
        getSharedPassword( withKey: key.mnemonic ) != nil
    }
    
    var body: some View {
        //GeometryReader { geometry in
        HStack {
            VStack( alignment: .leading ) {
            
                HStack {
                    Text( key.mnemonic )
                        .padding(6)
                        .background( Color.blue)
                        .clipShape(Capsule())
                        
                    Spacer()
                    if( isShared ) {
                        Button( action:{} ) {
                            Image( systemName: "eye.slash")
                        }.buttonStyle(PlainButtonStyle())
                    }
                    else {
                        Image( systemName: "icloud.slash")
                            .foregroundColor(Color.red)
                    }
                    
                }
                .font(Font.system(.title))
                
                Divider()
                
                
                
                if let mail = key.mail, !mail.isEmpty {
                    
                    if( mail == key.username ) {
                        doubleLabel( "person.circle.fill", "envelope.fill") { Text(key.username) }
                    }
                    else {
                        label("person.circle.fill") { Text(key.username) }
                        label("envelope.fill") { Text( mail) }
                    }
                }
                else {
                    label("person.circle.fill") { Text(key.username) }
                }
                if let url = key.url, !url.isEmpty {
                
                    label("link" ) { Text(url) }

                }
                /*
                HStack {
                    label("envelope") { Text( getSharedPassword( withKey: key.mnemonic ) ?? "NONE"  ) }
                }
                */
            }
            .padding()
            Spacer()
        }.border(Color.gray, width: 1)
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
}

struct KeyItemRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let key = { () -> KeyEntity in
            
            let key = KeyEntity( entity:KeyEntity.entity(), insertInto: context )
            
            key.mnemonic = "MNEMONIC"
            key.username = "bartolomeo.sorrentino@soulsoftware.it"
            key.mail = "bartolomeo.sorrentino@soulsoftware.it"
            key.url = "http://usernamesite.com"

            return key
        }
        return KeyItemRow( key:key() )
    }
}
