//: A UIKit based Playground for presenting user interface

// see [Change TextEditor background in iOS 16](https://nilcoalescing.com/blog/ChangeTextEditorBackground/#:~:text=Starting%20from%20iOS%2016%20we,background%20won%27t%20be%20visible.)

import UIKit
import PlaygroundSupport


import SwiftUI


func textHeight( font: UIFont? = nil ) -> CGFloat  {
//   let fontForMetric = font ??  UIFont.systemFont( ofSize: UIFont.systemFontSize )
    let fontForMetric = font ?? UIFont.preferredFont(forTextStyle: .body)
    let contentSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
     // Get the height of a single text line
   let boundingRect = "ABC".boundingRect(    with: contentSize,
                                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                                              attributes: [NSAttributedString.Key.font: fontForMetric ],
                                              context: nil )
  
   return boundingRect.height
}
struct LinedTextEditor: View {
    @State private var text: String = ""
    
    var body: some View {
        TextEditor(text: $text)
            .lineLimit(24)
            .scrollContentBackground(.hidden)
            .background( LinedBackground() )
            .onTapGesture {
                // Close the keyboard when tapping outside the TextEditor
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

struct LinedBackground: View {
    var body: some View {
        
        GeometryReader { geometry in
            Path { path in
                let lineSpacing:CGFloat = 4.0
//                let lineHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight + lineSpacing
                let lineHeight =  textHeight()
                let lines = Int(geometry.size.height / lineHeight)
                
                for line in 1...lines {
                    let y = CGFloat(line) * lineHeight
                    path.move(to: CGPoint(x: 0, y: y + lineSpacing))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.black.opacity(1.5))
        }
        .background(Color.yellow).opacity(0.5)
        
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = UIHostingController(rootView: LinedTextEditor())
