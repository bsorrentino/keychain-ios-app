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
    ) var keyFethedResults: FetchedResults<KeyEntity>
    
    @State private var showModal = false
    
    @ObservedObject var reportInfo = KeysProcessingReport()
    
    var body: some View {
        NavigationView {
            FileManagerView { (url) in
                Text( url.lastPathComponent )
            }.sheet(isPresented: $showModal, onDismiss:  {
                
            }) {
                BackupReportView( info: self.reportInfo ).onAppear( perform: { self.backup() } )
            }
            .navigationBarTitle( Text("Backup"), displayMode: .large)
            .navigationBarItems(trailing:
                VStack {
                    Button( action: { self.showModal = true}) {
                        HStack {
                            Text( "Run" )
                            Image( systemName:"arrow.down.doc.fill" )
                        }
                    }
                })
        }
    }
    
    private func encodeKey( encoder:JSONEncoder, k:KeyEntity ) -> KeyEntity? {
        
        reportInfo.processed += 1
        
        do {
            let _ = try encoder.encode(k)
            
            return k
            //return String( data: data, encoding: .utf8  )
        }
        catch  {
                
            reportInfo.errors.append(error)
            
            return nil
        }

    }
    
    private func backup() {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
             reportInfo.errors.append( "Document Directory doesn't exist" )
             reportInfo.terminated = true
             return
         }

        let encoder = JSONEncoder()
        
        let keys = keyFethedResults
            .map( { k in encodeKey(encoder: encoder, k: k ) } )
            .filter({ data in data != nil} )
           
        do {
            
            let allEncodedData = try encoder.encode( keys )

            restore(from: allEncodedData)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let url = path.appendingPathComponent("backup-\(formatter.string(from: Date()))").appendingPathExtension("json")
            
            print( "backup file: \(url)")
            
            try allEncodedData.write(to: url )
            
            print( String( data:allEncodedData, encoding: .utf8 ) ?? "{}" )
            
        }
        catch {
            reportInfo.errors.append(error)
        }
        
        reportInfo.terminated = true
        
    }

    private func decodeKey( decoder:JSONDecoder, from data:Data ) -> KeyItem? {
        
        //reportInfo.processed += 1
        
        do {
            let data = try decoder.decode(String.self, from: data)
            
            return try decoder.decode(KeyItem.self, from: data.data(using: .utf8)!)
        }
        catch  {
                
            //reportInfo.errors.append(error)
            print( "error \(error)")
            return nil
        }

    }

    private func restore( from encodedData: Data) {
        
        let decoder = JSONDecoder()
        
        do {
            
            let allDecodedData = try decoder.decode( Array<KeyItem>.self, from: encodedData )

            print( "restore \(allDecodedData)")
            
            /*
            allDecodedData
                .map { data in decodeKey(decoder: decoder, from: data) }
                .filter { k in k != nil }
                .forEach { k in print( "\(k?.mnemonic ?? "undefined")" ) }
            */
                
        }
        catch {
            print( "restore error: \(error)" )
            //reportInfo.errors.append(error)
        }
        
        reportInfo.terminated = true
        
    }
}

struct BackupReportView : View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var info:KeysProcessingReport
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("Processed:")
                Text( String(info.processed) )
            }
            HStack {
                Text("Errors:")
                Text( String(info.errors.count) )
            }
            
            Button( action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Close")
            }.disabled( !info.terminated )
        }
    }
}

struct BackupKeysView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            BackupKeysView()
            BackupReportView( info: KeysProcessingReport() )
        }
    }
}
