//
//  FileManagerView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared

extension URL {
    func isJSON() -> Bool {
        return self.lastPathComponent.hasSuffix(".json")
    }
    
    func isPLIST() -> Bool {
        return self.lastPathComponent.hasSuffix(".plist")
    }

}

struct FileManagerView<Content> : View where Content : View {
    
    typealias Result = (urls:[URL], error:Error? )
    
    private var content:(URL) -> Content
    
    init( @ViewBuilder _ content: @escaping (URL) -> Content ) {
        self.content = content
    }
    
    func backupUrls() -> Result {
        
        guard !isInPreviewMode else {
            return ( urls:[ URL(fileURLWithPath: "file://backup.fake") ], error:nil )
        }
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ( urls:[], error:"Document Directory doesn't exist" )
        }
        
        logger.trace( "\(path.absoluteString)" )
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: path,
                                               includingPropertiesForKeys: nil,
                                               options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants] )
            
            let result = urls
                    .filter { $0.isFileURL && ($0.isJSON() || $0.isPLIST()) }
            
            return ( urls:result, error:nil )
            
        }
        catch {
            
            return ( urls:[], error:error )
        }
    }
    
    var body: some View {
        
        let result = backupUrls()
        
        Group {
            
            if( result.error != nil )  {
                 Text( "error occurred")
            }
            else  {
                if( result.urls.isEmpty ) {
                    Text( "no data found")
                }
                else {
                    List( result.urls, id: \URL.self ) { url in
                        self.content(url)
                    }
                }
            }
        }
    }
    
}
