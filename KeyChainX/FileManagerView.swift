//
//  FileManagerView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



struct FileManagerView: View {
    
    typealias Result = (urls:[URL], error:Error? )
    
    func backupUrls() -> Result {
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return ( urls:[], error:"Document Directory doesn't exist" )
        }
        
        print(path.absoluteString)
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: path,
                                               includingPropertiesForKeys: nil,
                                               options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants] )
            let result = urls
                .map { url -> URL in
                    print(url);
                    return url
                }
                .filter { (url) -> Bool in
                    return url.isFileURL && url.lastPathComponent.hasSuffix(".plist")
                }
                                                    
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
                            Text( url.lastPathComponent )
                        }
                    }
                }
            }
        }
    }
}
