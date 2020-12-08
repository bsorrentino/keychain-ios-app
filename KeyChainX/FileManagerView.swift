//
//  FileManagerView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

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
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return ( urls:[], error:"Document Directory doesn't exist" )
        }
        
        print(path.absoluteString)
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: path,
                                               includingPropertiesForKeys: nil,
                                               options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants] )
#if targetEnvironment(simulator) && false
            let result = [ URL(fileURLWithPath: "file://test.plist") ]
#else
            let result = urls
                .filter { (url) -> Bool in
                    return url.isFileURL && (url.isJSON() || url.isPLIST())
                }
#endif
            return ( urls:result, error:nil )
            
        }
        catch {
            
            return ( urls:[], error:error )
        }
    }

    
    var body: some View {
        
        let result = backupUrls()
        
        return Group {
            
            if( result.error != nil )  {
                 Text( "error occurred")
            }
            else  {
                if( result.urls.isEmpty ) {
                    Text( "no data found")
                }
                else {
                    List {
                        ForEach( result.urls, id: \URL.self ) { url in
                            self.content(url)
                        }
                    }
                }
            }
        }
    }
    
}
