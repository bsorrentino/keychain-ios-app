//
//  SearchBar.swift
//  MacKeyChainX
//
//  Created by softphone on 12/04/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Cocoa

struct SearchBar: NSViewRepresentable {
    

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, NSSearchFieldDelegate {

        @Binding var text: String
        
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func controlTextDidChange(_ notification: Notification) {
            if let textField = notification.object as? NSTextField {
                text = textField.stringValue
                //do what you need here
            }
        }

//        func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        }
        
        func searchFieldDidEndSearching(_ sender: NSSearchField) {
            text = ""
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeNSView(context: NSViewRepresentableContext<SearchBar>) -> NSSearchField {
        let searchBar = NSSearchField(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholderString = placeholder
        //searchBar.searchBarStyle = .minimal
        //searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateNSView(_ uiView: NSSearchField, context: NSViewRepresentableContext<SearchBar>) {
        uiView.stringValue = text
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), placeholder: "type search....")
    }
}
