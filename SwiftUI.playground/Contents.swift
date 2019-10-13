import UIKit
import PlaygroundSupport
import SwiftUI
import Combine


// MARK:  FIELD VALIDATION

struct FieldChecker {
    
    var errorMessage:String? = nil
    
    var valid:Bool {
         self.errorMessage == nil
     }

}

class FieldValidator<T> : ObservableObject where T : Hashable {
    typealias Validator = (T) -> String?
    
    @Binding private var bindValue:T
    @Binding private var checker:FieldChecker
    
    @Published var value:T
    {
        willSet {
            self.doValidate(newValue)
        }
        didSet {
            self.bindValue = self.value
        }
    }
    private let validator:Validator
    
    var isValid:Bool {
        self.checker.valid
    }
    
    var errorMessage:String? {
        self.checker.errorMessage
    }
    
    init( _ value:Binding<T>, checker:Binding<FieldChecker>, validator:@escaping Validator  ) {
        self.validator = validator
        self._bindValue = value
        self.value = value.wrappedValue
        self._checker = checker
    }
    
    func doValidate( _ newValue:T? = nil ) -> Void {
                
        self.checker.errorMessage =
                        (newValue != nil) ?
                            self.validator( newValue! ) :
                            self.validator( self.value )
    }
}


// MARK:  FORM FIELD

struct TextFieldWithValidator : View {
    typealias Validator = (String) -> String? // specialize validator for TestField ( T = String )
    
    var title:String?
    
    @ObservedObject var field:FieldValidator<String>
    
    init( title:String = "", value:Binding<String>, checker:Binding<FieldChecker>, validator:@escaping Validator ) {
        self.title = title;
        self.field = FieldValidator<String>(value, checker:checker, validator:validator )
        
    }

    var body: some View {
        VStack {
            TextField( title ?? "", text: $field.value )
                .padding(.all)
                .border( field.isValid ? Color.clear : Color.red )
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                //.cornerRadius(5.0)
                .onAppear {
                    self.field.doValidate()
                }
                if( !field.isValid  ) {
                    Text( field.errorMessage ?? "" )
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(Color.red)

                }
        }
    }
}

// MARK: SAMPLE
class DataItem: /*Codable,*/ ObservableObject {

    @Published var username:String = ""
    @Published var password:String = ""

}


struct FormVithValidator : View {

    @ObservedObject var item:DataItem
    
    @State var usernameValid = FieldChecker()
    @State var passwordValid = FieldChecker()

    var body: some View {
        Form {
             
             Section {
                 
                TextFieldWithValidator( title:"username", value: $item.username, checker:$usernameValid ) { v in
                         
                         if( v.isEmpty ) {
                             return "username cannot be empty"
                         }
                         
                         return nil
                 }
                 .autocapitalization(.none)
                TextFieldWithValidator( title:"password", value: $item.password, checker:$passwordValid ) { v in
                         
                         if( v.isEmpty ) {
                             return "password cannot be empty"
                         }
                         
                         return nil
                 }
                 .autocapitalization(.none)
            }
            Section {
                Button( "Submit" ) {
                    
                }
                .disabled( !(passwordValid.valid && usernameValid.valid) )
            }
         }

    }
}

let item = DataItem()

let window = UIWindow( frame:CGRect(x:0, y:0, width:768, height:1024) )

let vc = UIHostingController(rootView: FormVithValidator( item:item))

UIScreen.main.bounds

window.rootViewController = vc
window.makeKeyAndVisible()
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true
