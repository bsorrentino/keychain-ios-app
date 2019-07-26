//
//  ContentView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 06/06/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

typealias ViewProvider = (( KeyItem ) -> UIView );


struct KeyItemList: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = KeyItemListViewController
    
    var controller:KeyItemListViewController
    
    public init( _ items:[KeyItem]/*, cellView:@escaping ViewProvider*/ ) {
        
        self.controller = KeyItemListViewController()
        
        self.controller.items = items
        //self.controller.cellView = cellView
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyItemList>) -> UIViewControllerType {
        
        print( "makeUIViewController" )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<KeyItemList>) {
        //
        print( "updateUIViewController" )
        self.controller.tableView.reloadData()
    }
}

struct ContentView : View {

    var items:[KeyItem]

    var body: some View {
        NavigationView {
            TopView( items:items )
                .navigationBarTitle( Text("Key List") )
        }

    }
}

struct TopView : View {
    
    let form = DynamicNavigationDestinationLink( id:\KeyItem.self ) { data in
        KeyItemForm( item: data)
    }
    
    var items:[KeyItem]
    
    var body: some View {
        KeyItemList(items)
            .navigationBarItems(trailing:
            HStack {
                Button( action: {
                    self.form.presentedData?.value =
                        KeyItem( id:"id1", username: "user1")
                }, label: {
                    Image( systemName: "plus" )
                })
        })
    }
    
    
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(items: [
            KeyItem( id:"item1", username:"user1"),
            KeyItem( id:"item2", username:"user2"),
            KeyItem( id:"item3", username:"user3"),
        ])
    }
}
#endif
