//
//  File.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 19/08/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import SwiftUI


class KeysProcessingReport : ObservableObject {
    
    @Published var processed:Int = 0
    @Published var errors = Array<Error>()
    @Published var terminated:Bool = false {
        didSet {
            if terminated {
                url = nil
            }
        }
    }
    
    var url:URL? = nil
    
    func reset() {
        processed = 0
        errors.removeAll()
        terminated = false
    }
}


struct ProcessingReportView : View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var processingInfo:KeysProcessingReport
    
    var body: some View {
        
        VStack(spacing:10) {
            Text("Report").font(.title).padding()
            
            Spacer()
            
            HStack {
                Text("Processed:")
                Text( String(processingInfo.processed) )
            }.padding()
            
            HStack {
                Text("Errors:").foregroundColor(Color.red)
                Text( String(processingInfo.errors.count) )
            }.padding()
            
            Divider()
            
            Button( action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Close")
            }
            .disabled( !processingInfo.terminated )
            .padding()
            
            Spacer()
        }
    }
}

struct ProcessingReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProcessingReportView( processingInfo: KeysProcessingReport() )
    }
}
