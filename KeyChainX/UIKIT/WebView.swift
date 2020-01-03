//
//  WebView.swift
//  KeyChainX
//
//  Created by softphone on 03/01/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary
import WebKit
  


struct WebView : UIViewRepresentable {
    
    typealias UIViewType = WKWebView
    
    var url:URL?
    @Binding var reload:Bool
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let view =  WKWebView()

        view.allowsBackForwardNavigationGestures = true
        
        view.navigationDelegate = context.coordinator
        
        if let url = self.url {
            view.load( URLRequest( url:url ) )
        }

        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
        print( "WebView.updateUIView - reload:\(reload)" )
        if let url = self.url, reload {
            uiView.load( URLRequest( url:url ) )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }
       
}

class Coordinator :NSObject,  WKNavigationDelegate {

    //MARK:- WKNavigationDelegate
    var owner:WebView
    
    init( owner:WebView ) {
        self.owner = owner
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        //print("ERROR: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        owner.reload = false
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print("decidePolicyFor")
        
        decisionHandler(.allow)
    }
}

#if DEBUG
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            Text("TOP")
            
            WebView( url: URL(string: "https://www.google.com"), reload:.constant(false) )
            
            Text("BOTTOM")
        }
    }
}
#endif

