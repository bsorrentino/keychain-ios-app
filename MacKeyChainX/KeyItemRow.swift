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
    
    func label<Content>( _ label:String, @ViewBuilder content: () -> Content ) -> some View where Content : View  {
        VStack( alignment: .leading ) {
            Text( label )
            content()
        }
    }
    
    var body: some View {
        //GeometryReader { geometry in
        HStack {
            VStack( alignment: .leading ) {
                Text( key.mnemonic )
                HStack {
                    label("username") { Text(key.username) }
                    label("password") { Text( getSharedPassword( withKey: key.mnemonic ) ?? "NONE"  ) }
                }
                HStack {
                    label("mail") { Text( key.mail ?? "") }
                    label("url" ) { Text( key.url ?? "") }
                }
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
            
            key.mnemonic = "mnemonic"
            key.username = "bartolomeo.sorrentino@soulsoftware.it"
            key.mail = "bartolomeo.sorrentino@soulsoftware.it"
            key.url = "http://usernamesite.com"

            return key
        }
        return KeyItemRow( key:key() )
    }
}
