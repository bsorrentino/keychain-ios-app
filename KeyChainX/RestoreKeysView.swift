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

            let array = try NSArray( contentsOf: data.url!, error: () )
    
            print( "# object to import: \(array.count) " )
            
            try backupData(to: "backup", from: managedObjectContext)
                        
            try deleteAll( into: managedObjectContext )
        
            array.filter { (elem) in
                guard let dict = elem as? NSDictionary else {
                    return false
                }
                
                if let _ = dict["version"] as? String {
                    return false
                }
                
                return true
                
            }
            .forEach { (elem) in
                
                if let dict = elem as? NSDictionary {
                    
                    do {
                        
                        let item = try KeyItem( dictionary: dict )
                    
                        print(
                            """
                            
                            mnemonic:       \(item.mnemonic)
                            groupPrefix:    \(item.groupPrefix ?? "nil")
                            group:          \(item.group ?? false)
                            
                            """)
                        item.insert(into: managedObjectContext)
                        
                    }
                    catch {
                        print( "ERROR \(error)" )
                    }
                }
            }
            
            try managedObjectContext.save()
        }
        catch {
            
            self.data.error = error
            
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
