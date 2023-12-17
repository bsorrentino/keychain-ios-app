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
    
    private var content:([URL]) -> Content
    private var urls:[URL]
    
    init( urls:[URL], @ViewBuilder _ content: @escaping ([URL]) -> Content ) {
        self.urls = urls
        self.content = content
    }
        
    var body: some View {
        
        if( urls.isEmpty ) {
            Text( "No files found!")
                .font(.title)
        }
        else {
            //List( urls, id: \URL.self ) { url in
                self.content(urls)
            //}
        }
    }
    
}
