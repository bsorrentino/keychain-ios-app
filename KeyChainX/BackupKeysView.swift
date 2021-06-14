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
    
    @FetchRequest( fetchRequest: KeyEntity.fetchRequest() )
    var keyFethedResults: FetchedResults<KeyEntity>
    
    @State private var showReportView = false
    @State private var alertItem:AlertItem?
    
    @ObservedObject var backupInfo = KeysProcessingReport()
    
    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                Text( url.lastPathComponent )
            }.sheet(isPresented: $showReportView, onDismiss:  {
                
            }) {
                ProcessingReportView( processingInfo: self.backupInfo ).onAppear( perform: {
                        self.performBackup()
                })
            }
            .navigationBarTitle( Text("Backup"), displayMode: .large)
            .navigationBarItems(trailing:
                VStack {
                    Button( action: { self.prepareBackup()}) {
                        HStack {
                            Text( "Run" )
                            Image( systemName:"arrow.down.doc.fill" )
                        }
                    }
            }).alert( item: $alertItem ) { item in makeAlert(item:item) }
 
        }
    }
    
    private func encodeKey( encoder:JSONEncoder, k:KeyEntity ) -> KeyEntity? {
        
        backupInfo.processed += 1
        
        do {
            let _ = try encoder.encode(k)
            
            return k
            //return String( data: data, encoding: .utf8  )
        }
        catch  {
                
            backupInfo.errors.append(error)
            
            return nil
        }

    }
    
    private func prepareBackup()  {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            alertItem = makeAlertItem( error:"Document Directory doesn't exist",
                 primaryButton: .cancel({
                     self.backupInfo.terminated = true
                 }))
            return

         }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        backupInfo.url = path.appendingPathComponent("backup-\(formatter.string(from: Date()))").appendingPathExtension("json")
        
        if( FileManager.default.fileExists( atPath: backupInfo.url!.path ) ) {
            
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

        backupInfo.reset()

        guard let url = self.backupInfo.url else {
            backupInfo.terminated = true
            return
        }
        
        let encoder = JSONEncoder()
        
        do {
            logger.trace( "backup file: \(url)")
            
            let keys = keyFethedResults
                .map( { k in encodeKey(encoder: encoder, k: k ) } )
                .filter({ data in data != nil} )
            let allEncodedData = try encoder.encode( keys )

            try allEncodedData.write(to: url )
            
            //logger.trace( String( data:allEncodedData, encoding: .utf8 ) ?? "{}" )
            
        }
        catch {
            backupInfo.errors.append(error)
        }
        
        backupInfo.terminated = true
        
    }
    
}




struct BackupKeysView_Previews: PreviewProvider {
    static var previews: some View {
        
        BackupKeysView()
    }
}
