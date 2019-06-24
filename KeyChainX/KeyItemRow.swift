//
//  KeyItemRow.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct KeyItemRow : View {
    var item: KeyItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text( item.id.uppercased() )
            Text( item.grouped ? item.groupPrefix ?? "" : item.username )
                .font(.subheadline)
                .italic()
                .color(Color.gray)
        }
    }
}

#if DEBUG
struct KeyItemRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            KeyItemRow( item: KeyItem( id: "the mnemonic item", username: "bsorrentino"))
        }.previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif