//
//  BackupKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



struct BackupKeysView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: KeyEntity.entity(),
        sortDescriptors: []
    ) var keyResults: FetchedResults<KeyEntity>
    
    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                Text( url.lastPathComponent )
            }
            .navigationBarTitle( Text("Backup"), displayMode: .large)
            .navigationBarItems(trailing: VStack {
                Button( action: {
                    self.backup()
                }) {
                    HStack {
                        Text( "Run" )
                        Image( systemName:"arrow.down.doc.fill" )
                    }
                }
            })
        }
    }
    
    func backup() {
        
        let _ = JSONEncoder()
        
        keyResults.forEach { key in
            
        }
        
    }
}


struct BackupKeysView_Previews: PreviewProvider {
    static var previews: some View {
        BackupKeysView()
    }
}
