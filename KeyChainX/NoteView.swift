//
//  NoteView2.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 25/08/23.
//  Copyright © 2023 Bartolomeo Sorrentino. All rights reserved.
//

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


struct NoteView: View {
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .background( LinedBackground() )
        //            .onTapGesture {
        //                // Close the keyboard when tapping outside the TextEditor
        //                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //            }
    }
}

struct LinedBackground: View {
    var body: some View {
        
        GeometryReader { geometry in
            Path { path in
                let lineSpacing:CGFloat = 4.0
                let lineHeight =  textHeight()
                let lines = Int(geometry.size.height / lineHeight)
                
                for line in 1...lines {
                    let y = CGFloat(line) * lineHeight
                    path.move(to: CGPoint(x: 0, y: y + lineSpacing))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y + lineSpacing))
                }
            }
            .stroke(Color.gray.opacity(0.2))
        }
        //.background(Color.gray)
        
    }
}


struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView( text: Binding.constant("""

these are my note:

note1

note2


"""))
    }
}
