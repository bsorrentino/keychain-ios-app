//
//  BackupKeysView.swift
//  KeyChainX
//
//  Created by softphone on 28/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI



struct BackupKeysView: View {
    var body: some View {
        NavigationView {
            FileManagerView()
                .navigationBarTitle( Text("Backup"), displayMode: .large)
        }
    }
}

struct BackupKeysView_Previews: PreviewProvider {
    static var previews: some View {
        BackupKeysView()
    }
}
