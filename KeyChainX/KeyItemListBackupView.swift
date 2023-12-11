//
//  BackupKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared
import SwiftData

struct BackupKeysView: View {
    @Environment(\.modelContext) var context
    
    @Query(KeyInfo.fetchOrdered()) var keyFetchedResults: [KeyInfo]
    
    @State private var showReportView = false
    @State private var alertItem:AlertItem?
    
    @ObservedObject var processingInfo = KeysProcessingReportObject()
    
    @ObservedObject var backupInfo: KeysBackupInfoObject
    
    var body: some View {
        NavigationView {
            
            FileManagerView(urls: backupInfo.urls ) { url in
                Text( url.lastPathComponent )
            }
            .onChange(of: self.showReportView ) { (_, _) in
                performBackup()
            }
            .sheet(isPresented: $showReportView, onDismiss: {
                if( processingInfo.terminated ) {
                    backupInfo.loadBackupUrls()
                }
            }) {
                ProcessingReportView( processingInfo: processingInfo )
            }
            .navigationBarTitle( Text("Backup"), displayMode: .large)
            .navigationBarItems(trailing:
                VStack {
                    Button { self.prepareBackup() }
                    label: {
                            Text( "start" )
                            // Image( systemName:"arrow.down.doc.fill" )
                        // }
                    }
            })
            .alert( item: $alertItem ) { item in makeAlert(item:item) }
        }

    }
    
    private func encodeKey( encoder:JSONEncoder, k:KeyInfo ) -> KeyInfo? {
        
        processingInfo.processed += 1
        
        do {
            let _ = try encoder.encode(k)
            
            return k
            //return String( data: data, encoding: .utf8  )
        }
        catch  {
                
            processingInfo.errors.append(error)
            
            return nil
        }

    }
    
    private func prepareBackup()  {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            alertItem = makeAlertItem( error:"Document Directory doesn't exist",
                 primaryButton: .cancel({
                     self.processingInfo.terminated = true
                 }))
            return

         }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        processingInfo.url = path.appendingPathComponent("backup-\(formatter.string(from: Date()))").appendingPathExtension("json")
        
        if( FileManager.default.fileExists( atPath: processingInfo.url!.path ) ) {
            
            alertItem = AlertItem( title: Text("Overwrite"),
                                   message:Text("File Already Exists. Do you want overwrite ?"),
                                   primaryButton: .destructive( Text("Overwrite"), action: {
                                        self.showReportView = true
                                   }),
                                   secondaryButton: .cancel({
                                        logger.info("backup aborted")
                                    
                                   }) )
        }
        else {
            self.showReportView = true
        }
        
    }
    
    private func performBackup( )  {

        processingInfo.reset()

        guard let url = processingInfo.url else {
            processingInfo.terminated = true
            return
        }
        
        let encoder = JSONEncoder()
        
        do {
            logger.trace( "backup file: \(url)")
            
            let keys = keyFetchedResults
                .map( { k in encodeKey(encoder: encoder, k: k ) } )
                .filter({ data in data != nil} )
            let allEncodedData = try encoder.encode( keys )

            try allEncodedData.write(to: url )
            
        }
        catch {
            processingInfo.errors.append(error)
        }
        
        processingInfo.terminated = true
        
    }
    
}

struct BackupKeysView_Previews: PreviewProvider {
    
    struct MyPreview : View {
        
        @StateObject var backupInfo = KeysBackupInfoObject()
        
        var body: some View {

            BackupKeysView( backupInfo: backupInfo )
        }
        
    }
    static var previews: some View {
        
        MyPreview()
            .environment(\.colorScheme, .dark)
        MyPreview()
            .environment(\.colorScheme, .light)
    }
}
