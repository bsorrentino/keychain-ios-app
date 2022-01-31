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
    
    
    @State private var showingSheet = false
    @State private var alertItem:AlertItem?
    @State private var showReportView = false
    
    @ObservedObject var restoreInfo = KeysProcessingReport()
    
    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                //GeometryReader { geom in
                    HStack {
                        Text( url.lastPathComponent )
                            .font(.system(size: 25 ))
                        Spacer()
                        Button( action: {
                            self.restoreInfo.url = url
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
                        .actionSheet(isPresented: self.$showingSheet) {
                            ActionSheet(title: Text("Modality"),
                                        message: Text("How want to restore keys"),
                                        buttons: [
                                            //.default(Text("Add missing")) {},
                                            .destructive(Text("Replace All")) {
                                                self.prepareRestore()
                                            },
                                            .cancel(Text("Dismiss"))
                                            ])
                        }
                        .alert(item: self.$alertItem) { item in makeAlert(item:item) }
                        
                    }.padding(0.0)
                //}
            }
            .navigationBarTitle( Text("Restore"), displayMode: .large)
            .sheet( isPresented: self.$showReportView) {
                ProcessingReportView( processingInfo: self.restoreInfo).onAppear( perform: {
                    self.performRestore()
                })

            }

        }
    }

    typealias Keys = Array<KeyItem>
    
    private func prepareRestore() {
        
        do {
            try Shared.deleteAllWithMerge( context: managedObjectContext )
            
            showReportView = true
        }
        catch {
            
            self.alertItem = makeAlertItem( error:"Error Deleting Data [\(error)]" )
        }
    }
    
    private func performRestore() {
        
        self.restoreInfo.reset()

        guard let url = self.restoreInfo.url else {
            self.restoreInfo.terminated = true
            return
        }
        
        do {

            let content = try Data(contentsOf: url)

            var keys:Keys?
            
            if( url.isJSON() ) {
                keys = try restoreJSON( from:content )
            }
            else if( url.isPLIST() ) {
                keys = try restorePLIST( from:content )
            }
            
            if let keys = keys  {

                logger.trace( "# object to import: \(keys.count) " )

                keys.forEach { item in
                    
//                    logger.trace(
//                        """
//
//                        mnemonic:       \(item.mnemonic)
//                        groupPrefix:    \(item.groupPrefix ?? "nil")
//                        group:          \(item.group)
//
//                        """)
//
                    if( item.password.isEmpty && item.group ) {
                        logger.notice( "password for item \(item.mnemonic) not valid!")
                    }
                    
                    do {
                        restoreInfo.processed += 1
                        
                        try item.insert(into: managedObjectContext)
                    }
                    catch {
                        
                        restoreInfo.errors.append( error )
                    }
                }

                try managedObjectContext.save()

            }

        }
        catch {
            
            self.alertItem = makeAlertItem( error:"Error Restoring Data [\(error)]" )
        }
        
        restoreInfo.terminated = true
           
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
