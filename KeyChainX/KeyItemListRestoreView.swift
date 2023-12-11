//
//  RestoreKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

struct RestoreKeysView: View {
    enum Operation: String, Identifiable {
        case MergeAll
        case DeleteAll
        
        var id: String { rawValue }
    }
    
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingSheet = false
    @State private var alertItem:AlertItem?
    @State private var startRestore:Operation?
    
    @ObservedObject var processingInfo = KeysProcessingReportObject()
    
    @ObservedObject var backupInfo: KeysBackupInfoObject
    
    
    var body: some View {
        NavigationView {
            
            FileManagerView(urls: backupInfo.urls) { url in
            
                HStack {
                    Text( url.lastPathComponent )
                    Spacer()
                    Button {
                        processingInfo.url = url
                        showingSheet = true
                    } label: {
                        Label( "restore", systemImage: "" )
                            .labelStyle(TitleOnlyLabelStyle())
                    }
                    .buttonStyle(.bordered)
                    .if( colorScheme == .dark ) { $0.tint( .white ) }
                    .cornerRadius(20)
                    .actionSheet(isPresented: self.$showingSheet) {
                        ActionSheet(title: Text("Modality"),
                                    message: Text("How want to restore keys"),
                                    buttons: [
                                        .default(Text("Merge All")) {
                                            performRestore( .MergeAll )
                                            startRestore = .MergeAll
                                        },
                                        .destructive(Text("Delete All")) {
                                            performRestore( .DeleteAll )
                                            startRestore = .DeleteAll
                                        },
                                        .cancel(Text("Dismiss"))
                                        ])
                    }
                    .alert(item: self.$alertItem) { item in makeAlert(item:item) }
                    
                }
                .padding(0.0)
            }
            .sheet( item: $startRestore ) { operation in
//                switch operation  {
//                case .MergeAll:
//                    mergeAll()
//                case .DeleteAll:
//                    deleteAll()
//                }
                
                ProcessingReportView( processingInfo: processingInfo)
                
            }
            .navigationBarTitle( Text("Restore"), displayMode: .large)

        }
    }

    typealias Keys = Array<KeyItem>
    
    
    private func performRestore( _ operation: Operation ) {
        
        self.processingInfo.reset()

        guard let url = self.processingInfo.url else {
            self.processingInfo.terminated = true
            return
        }
        
        do {
            if operation == .DeleteAll  {
                try KeyInfo.deleteAll( context )
            }

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
                    
                    if( item.password.isEmpty && item.group ) {
                        logger.notice( "password for item \(item.mnemonic) not valid!")
                    }

                    do {
                        if operation == .MergeAll {
    
                            if let entity = try KeyInfo.fetchSingleIfPresent( mnemonic: item.mnemonic, inContext: context )  {
                                logger.debug( "merge entity \(item.mnemonic)")
                                try item.attach( entity: entity )
                            }
                            
                        }
                    
                        processingInfo.processed += 1
                        
                        try item.insertOrUpdate(into: context)
                    }
                    catch {
                        
                        processingInfo.errors.append( error )
                    }
                }

                try context.save()

            }

        }
        catch {
            
            self.alertItem = makeAlertItem( error:"Error Restoring Data [\(error)]" )
        }
        
        processingInfo.terminated = true
           
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


struct RestoreKeysView_Previews: PreviewProvider {
    
    struct MyPreview : View {
        
        @StateObject var backupInfo = KeysBackupInfoObject()
        
        var body: some View {

            RestoreKeysView( backupInfo: backupInfo )
        }
        
    }
    static var previews: some View {
        
        MyPreview()
            .environment(\.colorScheme, .dark)
        MyPreview()
            .environment(\.colorScheme, .light)
    }
}

