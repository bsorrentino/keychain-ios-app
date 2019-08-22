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
    
    var keys:ApplicationKeys
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyItemList>) -> UIViewControllerType
    {
        print( "makeUIViewController" )
        let controller =  KeyItemListViewController(style: .grouped)
        
        controller.keys = keys
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyItemList>) {
        
        print( "updateUIViewController \(keys.items.count)" )
        
        uiViewController.reloadData()
    }
}

struct ContentView : View {

    var body: some View {
        NavigationView {
            TopView()
                .navigationBarTitle( Text("Key List") )
        }

    }
}

struct TopView : View {
    
    @EnvironmentObject var keys:ApplicationKeys;

    var body: some View {
        KeyItemList( keys:keys)
            .navigationBarItems(trailing:
            HStack {
                NavigationLink( destination: KeyItemForm( item: KeyItem.newItem() ), label: {
                    Image( systemName: "plus" )
                })
        })
    }
    
    
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject( ApplicationKeys(items:[
            KeyItem( id:"item1", username:"user1"),
            KeyItem( id:"item2", username:"user2"),
            KeyItem( id:"item3", username:"user3"),
        ]) )
        
    }
}
#endif
