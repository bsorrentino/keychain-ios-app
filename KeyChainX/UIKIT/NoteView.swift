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
    private var observer:NSObjectProtocol?
    
    override init( frame: CGRect, textContainer: NSTextContainer? ) {
        super.init( frame: frame, textContainer: textContainer )
        
        self.isScrollEnabled = false
        self.isEditable = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = .yellow
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = true
        
        self.observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: .main)
            { (notification) in
                self.setNeedsDisplay()
            }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        // perform the deinitialization

        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func drawVerticalGuideLine( _ rect: CGRect, in context: CGContext ) {
        let line = ( offset:CGFloat(24.0), space:CGFloat(2.5))

        let x = rect.origin.x + rect.size.width - line.offset
        
        let startPoint  = CGPoint(x:x, y:rect.origin.y )
        let endPoint    = CGPoint(x:x, y:rect.origin.y + rect.size.height)

        context.setLineWidth(1)

        context.beginPath()

        context.move( to: startPoint)
        context.addLine(to: endPoint)

        let startPoint1 = CGPoint( x:startPoint.x + line.space, y:startPoint.y )
        let endPoint1 = CGPoint( x:endPoint.x + line.space, y:endPoint.y )

        context.move( to: startPoint1)
        context.addLine(to: endPoint1)

        context.setStrokeColor( lineColor.cgColor )

        context.drawPath(using: .stroke)
    }
    
    private func textHeight() -> CGFloat  {
               let fontForMetric = self.font ??  UIFont.systemFont( ofSize: UIFont.systemFontSize )
                 // Get the height of a single text line
               let boundingRect = "ABC".boundingRect(    with: self.contentSize,
                                                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                          attributes: [NSAttributedString.Key.font: fontForMetric ],
                                                          context: nil )
              
               return boundingRect.height
    }
    
    override func draw(_ rect: CGRect) {
        print( "draw \(rect)")
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setShouldAntialias(false)
          
        drawVerticalGuideLine( rect, in: context)
        
        let height = self.textHeight()
      
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
        let view = UINoteTextView()
        
        view.font = UIFont.systemFont( ofSize: 20 )
        
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


#if DEBUG

struct NoteTextView_Previews : PreviewProvider {
    static var previews: some View {
        NoteTextView( text: .constant("TEST") )
            .navigationBarTitle( Text("Note"), displayMode: .inline  )
            .navigationBarItems(trailing: Button("done") {
            })
    }
}
#endif
