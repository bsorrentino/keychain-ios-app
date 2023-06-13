//
//  PreferredView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 13/06/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Shared


struct PreferredView: View {
    
    @FetchRequest(fetchRequest: KeyEntity.fetchPreferred()) var preferred: FetchedResults<KeyEntity>
    
    
    var body: some View {
        List(preferred) { key in
            Text(key.mnemonic )
        }
    }
}

struct PreferredView_Previews: PreviewProvider {
    static var previews: some View {
        PreferredView()
    }
}
