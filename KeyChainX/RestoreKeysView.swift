//
//  RestoreKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI


struct RestoreKeysView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showingSheet = false
    @State var showingError = false
    @State var selectedURL:URL?
    @State var error:Error?

    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                //GeometryReader { geom in
                    HStack {
                        Text( url.lastPathComponent )
                            .font(.system(size: 25 ))
                        Spacer()
                        Button( action: {
                            self.selectedURL = url
                            self.showingSheet = true
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
            .navigationBarTitle( Text("Restore"), displayMode: .large)
            .actionSheet(isPresented: $showingSheet) {
                ActionSheet(title: Text("Modality"),
                            message: Text("How want to restore keys"),
                            buttons: [
                                //.default(Text("Add missing")) {},
                                .destructive(Text("Replace All")) {
                                    self.restore()
                                },
                                .cancel(Text("Dismiss"))
                                ])
            }
            .alert(isPresented: $showingError) {
                Alert(title: Text("Error Restoring Data"),
                      message: Text( error?.localizedDescription ?? "Unknown" ),
                      dismissButton: .default(Text("OK")))
            }

        }
    }

    typealias Keys = Array<KeyItem>
    
    func restore() {
        
        guard let url = selectedURL else {
            return
        }

        do {
            try UIApplication.deleteAllWithMerge( context: managedObjectContext )

            let content = try Data(contentsOf: url)

            var keys:Keys?
            
            if( url.isJSON() ) {
                keys = try restoreJSON( from:content )
            }
            else if( url.isPLIST() ) {
                keys = try restorePLIST( from:content )
            }
            
            if let keys = keys  {

                print( "# object to import: \(keys.count) " )

                try keys.forEach { item in
                    
//                    print(
//                        """
//
//                        mnemonic:       \(item.mnemonic)
//                        groupPrefix:    \(item.groupPrefix ?? "nil")
//                        group:          \(item.group)
//
//                        """)
//
                    if( item.password.isEmpty && item.group ) {
                        print( "password for item \(item.mnemonic) not valid!")
                    }
                    
                    try item.insert(into: managedObjectContext)
                            
                }

                try managedObjectContext.save()

            }

        }
        catch {
            print( "restore error \(error)" )
            self.error = error
            self.showingError = true
        }
    }
    
    func restoreJSON( from content:Data ) throws -> Keys {

        let decoder = JSONDecoder()

        return try decoder.decode( Keys.self, from: content )

    }
    
    func restorePLIST( from content:Data ) throws -> Keys  {
        
        let decoder = PropertyListDecoder()
       return try decoder.decode(Keys.self, from: content)

    }
}

#if DEBUG
struct RestoreKeysView_Previews: PreviewProvider {
    static var previews: some View {
            RestoreKeysView()
    }
}
#endif
