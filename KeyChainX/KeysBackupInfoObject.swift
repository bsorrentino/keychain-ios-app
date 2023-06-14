//
//  BackupInfo.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 14/06/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import Shared

@MainActor
class KeysBackupInfoObject : ObservableObject {

    @Published var urls:[URL] = []
    var loadingError:Error?
    
    init() {
        loadBackupUrls()
    }
    
    func loadBackupUrls() {
        
        guard !isInPreviewMode else {
            urls =  [ URL(fileURLWithPath: "file://backup.fake") ]
            return
        }
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            loadingError = "Document Directory doesn't exist"
            return
        }
        
        logger.trace( "\(path.absoluteString)" )
        
        do {
            let result = try FileManager.default.contentsOfDirectory(at: path,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants] )
            
            urls = result.filter { $0.isFileURL && ($0.isJSON() || $0.isPLIST()) }
            
        }
        catch {
            loadingError = error
        }
    }

}
