import SwiftUI
import PlaygroundSupport
import Combine

struct TextFieldWithValidator : View {

    var body: some View {
        VStack {
            TextField( "test", text: .constant("value") )
            .padding(.all)
            .border( Color.red  )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .cornerRadius(5.0)
            
            Text( "an error occurred" )
                .foregroundColor( Color.red)
                .font( .footnote )
                .fontWeight(.semibold)

            

        }
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = UIHostingController(rootView: TextFieldWithValidator())

