//
//  RestoreKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

class ViewData : ObservableObject {
    
    @Published var showingError = false
    @Published var showingSheet = false
    var error:Error?
    var url:URL?
}

struct RestoreKeysView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var data = ViewData()
    
    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                //GeometryReader { geom in
                    HStack {
                        Text( url.lastPathComponent )
                            .font(.system(size: 25 ))
                        Spacer()
                        Button( action: {
                            self.data.url = url
                            self.data.showingSheet = true
                        }) {
                            VStack {
                                Text("restore")
                                    .font(.system(size: 15 ))
                                    .foregroundColor(Color.white)
                            }
                            .padding( 10.0 )
                        }
                        .background(Color.secondary)
                        
                    }.padding(0.0)
                //}
            }
            .navigationBarTitle( Text("Backup"), displayMode: .large)
            .actionSheet(isPresented: $data.showingSheet) {
                ActionSheet(title: Text("Modality"),
                            message: Text("How want to restore keys"),
                            buttons: [
                                //.default(Text("Add missing")) {},
                                .destructive(Text("Replace All")) {
                                    self.restoreFrom()
                                },
                                .cancel(Text("Dismiss"))
                                ])
            }
            .alert(isPresented: $data.showingError) {
                Alert(title: Text("Error Restoring Data"),
                      message: Text( self.data.error?.localizedDescription ?? "Unknown" ),
                      dismissButton: .default(Text("OK")))
            }

        }
    }
    
    func restoreFrom(  ) {
        
        do {
            typealias Keys = [KeyItem]
            
            try backupData(to: "backup", from: managedObjectContext)
                        
            try deleteAll( into: managedObjectContext )
            
            let content = try Data(contentsOf: data.url!)
            let decoder = PropertyListDecoder()
            let array = try decoder.decode(Keys.self, from: content)

            print( "# object to import: \(array.count) " )

            array.filter { (item) in
                !item.mnemonic.isEmpty
            }
            .forEach { (item) in
                
                print(
                    """
                    
                    mnemonic:       \(item.mnemonic)
                    groupPrefix:    \(item.groupPrefix ?? "nil")
                    group:          \(item.group)
                    
                    """)
                
                item.insert(into: managedObjectContext)
                        
            }

            try managedObjectContext.save()
        }
        catch {
            
            print( error )
            self.data.error = error
            self.data.showingError = true
            
        }
    }
}

#if DEBUG
struct RestoreKeysView_Previews: PreviewProvider {
    static var previews: some View {
            RestoreKeysView()
    }
}
#endif
