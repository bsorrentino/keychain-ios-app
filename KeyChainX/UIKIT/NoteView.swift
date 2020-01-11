//
//  NoteView.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 11/01/2020.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import SwiftUI

let NOTE_MAGIC_NUMBER = CGFloat(7.5)

class UINoteTextView : UITextView {
    
    let lineColor = UIColor( red:202/255.0, green:167/255.0, blue:131/255.0, alpha:1.0 )
    
    convenience init( useFont font:UIFont ) {
        self.init()
        self.isScrollEnabled = true
        self.isEditable = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = .yellow

        self.font = font
        
    }

//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let line_offset:CGFloat = 24.0

        let startPoint  = CGPoint(x:line_offset, y:rect.origin.y)
        let endPoint    = CGPoint(x:line_offset, y:rect.origin.y + rect.size.height)
          

        context.setShouldAntialias(false)
          
        context.setStrokeColor( lineColor.cgColor )
          
        context.setLineWidth(1)
          
        context.beginPath()
        
        context.move( to: startPoint)
        context.addLine(to: endPoint)
        
        let startPoint1 = CGPoint( x:startPoint.x + 2.0, y:startPoint.y )
        let endPoint1 = CGPoint( x:endPoint.x + 2.0, y:endPoint.y )

        context.move( to: startPoint1)
        context.addLine(to: endPoint1)
          
        context.drawPath(using: .stroke)
        
        let _font =  self.font ??  UIFont.systemFont( ofSize: UIFont.systemFontSize )
        
        let _text = self.text ?? "ABC"
          // Get the height of a single text line
        let boundingRect = _text.boundingRect(    with: self.contentSize,
                                                   options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                   attributes: [NSAttributedString.Key.font: _font ],
                                                   context: nil )
       
        let height = boundingRect.height
      
        for i in stride(from: height + NOTE_MAGIC_NUMBER, through: self.bounds.height, by: height ) {
            
            let points = [ CGPoint(x: 0,y: i), CGPoint(x: rect.size.width,y: i) ]
            context.setLineWidth(0.5);
            context.strokeLineSegments(between: points )
        }
    }
    
}

class UINoteViewCoordinator : NSObject, UITextViewDelegate {
    
    var owner:NoteTextView
    
    init( owner:NoteTextView ) {
        self.owner = owner
    }
    func textViewDidChange(_ textView: UITextView) {
        self.owner.text = textView.text
    }
}


struct NoteTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UINoteTextView {
        let view = UINoteTextView( useFont: UIFont.systemFont(ofSize: 20) )
        
        view.delegate = context.coordinator
        
        return view
    }

    func updateUIView(_ uiView: UINoteTextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> UINoteViewCoordinator {
        UINoteViewCoordinator(owner:self)
    }


}
