//
//  KeyItemForm+Url.swift
//  KeyChainX
//
//  Created by softphone on 03/01/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary
import WebKit


fileprivate let urlRegEx = "^(https?://)?((?:www\\.)?(?:[-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(?:/[-\\w@\\+\\.~#\\?&/=%]*)?)$"

func parseUrl( _ url:String ) -> [String] {
    
    let result = url.groups( for:urlRegEx  )
    
    guard result.count == 1 && result[0].count == 3  else {
        return []
    }
    
    return result[0]
}

func isUrl( _ url:String ) -> Bool {
    
    return url.range(of: urlRegEx, options: .regularExpression) != nil
}

struct  UrlField : View {
    
    @Binding var value:String

    var body: some View {
        NavigationLink( destination: UrlView( value: $value) ) {
            HStack {
                Image( systemName: "link.circle").resizable().frame(width: 20, height: 20, alignment: .leading)
                if( value.isEmpty ) {
                    Text( "tap to choose url" )
                        .foregroundColor(.gray)
                        .italic()
                }
                else {
                    Text(value )
                }
            }
            .padding(EdgeInsets( top: 20, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
}


struct UrlView: View {

    @Environment(\.presentationMode) var presentationMode

    @Binding var value:String {
        
        willSet {
        }
    }
    
    @State var urlValid = FieldChecker()
    @State var urlReload = false
    
    
    var body: some View {

        VStack( spacing: 2.0 ) {
            
            TextFieldWithValidator( title: "insert url",
                                    value: $value,
                                    checker:$urlValid,
                                    onCommit: openUrl ) { v in
                   
                    if( v.isEmpty ) {
                       return "url cannot be empty !"
                    }
                    
                    if( !isUrl(v) ) {
                        return "url is not in correct format !"
                    }
                    
                    return nil
            }
            //.textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textContentType(.URL)
            .keyboardType(.URL)
            .font(.body)
            .padding( EdgeInsets(top:5, leading: 0, bottom: 25, trailing: 0) )
            .overlay(
                ValidatorMessageInline( message:urlValid.errorMessage ), alignment: .bottom
            )

            Divider()
            
            
            WebView( url: URL( string: value), reload:$urlReload )
            
        }
        //.padding()
        .navigationBarTitle( Text("url"), displayMode: .inline )
        .navigationBarItems(trailing: saveButton() )

    }
    
    private func saveButton() -> some View  {

        Button( action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text( "Save" )
        }.disabled( !urlValid.valid )

    }
    
    private func openUrl() {
        let capuredGroups = parseUrl(value)
        
        if( capuredGroups.count == 3  &&  capuredGroups[1].isEmpty ) {
            self.value = "https://\(capuredGroups[2])"
        }

        urlReload = urlValid.valid
    }
}

#if DEBUG
struct KeyItemForm_Url_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UrlView( value: .constant( "https://www.google.com"))
        }
    }
}
#endif
