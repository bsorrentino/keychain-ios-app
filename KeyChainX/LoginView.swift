//
//  LoginView.swift
//  keychain
//
//  Created by Bartolomeo Sorrentino on 06/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import LocalAuthentication
import SwiftUI
import Combine
import FieldValidatorLibrary

private let strikeWidth:CGFloat = 0.5


struct LoginView: View {
    
    class States : ObservableObject {
        @Published var show = true
    }

    @Environment(\.presentationMode) private var isPresented
    @Environment(\.UserPreferencesKeychain) private var userPreferencesKeychain
    @EnvironmentObject private var mcSecretsService :MCSecretsService
    
    
    @State var password:String = ""
    @State var passwordChecker   = FieldChecker()

    @State var confirmPassword:String = ""
    @State var confirmPasswordChecker   = FieldChecker()

    //@State private var showingAlert = false
    //@State private var authenticationError:String = ""
    @State var hidePassword = true
    
    private var  context = LAContext()

    // Dismiss after logging on
    private func dismiss() {
        self.isPresented.wrappedValue.dismiss()
        mcSecretsService.start()
    }
    
    private func checkError(  checker:@escaping () -> FieldChecker ) -> some View {
        
        let c = checker()
        
        return Text( c.errorMessage ?? "password is correct 👍🏻" )
            .fontWeight(.thin)
            .font(.footnote).italic()
            .foregroundColor( (c.valid) ? Color.green : Color.red)
            .padding(.top, 30)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                    
                Text( "KEYCHAIN" ).font(.title).fontWeight(.bold)
                Text( appVersion() ).font(.headline).fontWeight(.thin)
                
                Spacer()
                if self.isBiometricAvailable && self.hidePassword {

                    Button( action: {
                        self.authenticateWithBiometric()
                    }) {
                         VStack {
                            Image( systemName: "faceid" )
                                .resizable()
                                .frame(width: 50.0, height: 50.0, alignment: .center)
                            
                            Text( "Touch to authenticate with FaceID").padding(.top, 20).padding( .bottom, 10 )
                        }
                    }
                    Divider()
                    Button( action: {
                        self.hidePassword = false
                    }) {
                        Text( "or authenticate with your password")
                    }.padding(.top, 10)

    //                    .alert(isPresented: $showingAlert) {
    //                        Alert(  title: Text("Autheticazione Failed"),
    //                                message: Text(authenticationError),
    //                                dismissButton: .default(Text("Got it!")))
    //                    }
                    
                }
                else {
                    
                    if self.isPasswordHasBeenInserted {

                        self.passwordInput()
                        Divider()
                        self.checkError { self.passwordChecker }
        
                        Spacer()
                        
                        HStack() {
                            Spacer()
                            Button( action: self.dismiss ){
                                Text("Accept >").padding( .trailing, 20)
                            }
                            .disabled( !self.passwordChecker.valid )
                        }
                    
                    }
                    else {

                        self.passwordChooseInput()
                        self.passwordConfirmInput()
                        Divider()
                        self.checkError {
                            ( self.passwordChecker.valid ) ? self.confirmPasswordChecker : self.passwordChecker
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Button( action: self.savePasswordAndDismiss ){
                                Text("Accept >").padding( .trailing, 20)
                            }
                            .disabled( !(self.passwordChecker.valid && self.confirmPasswordChecker.valid) )
                        }
                    }
                }
                Spacer()

                    
                }.padding( EdgeInsets( top:0, leading:10, bottom:0, trailing:10  ))

                    
            }.navigationBarTitle( Text("Login"), displayMode: .large)
        .highPriorityGesture( DragGesture() ) // DISABLE DRAG GESTURE
    }
        
    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            SecureFieldWithValidator(
                title:"give me password",
                value:$password,
                checker:$passwordChecker,
                onCommit: submitPassword) { v in
                    
                    if( v.isEmpty ) {
                        return "password cannot be empty! ☹️"
                    }
                    
                    do {
                        guard let password = try self.getPassword() else {
                            return "password doesn't exist! 😱"
                        }
                        
                        if( password.compare(v) != .orderedSame) {
                            return "password doesn't match! 🤔"
                        }
                    }
                    catch {
                        
                        return error.localizedDescription
                    }
                                        
                    return nil
            }
            .autocapitalization(.none)
            .multilineTextAlignment(.center)
            .padding( 10.0 )
//            .overlay( RoundedRectangle(cornerRadius: 10)
//                        .stroke(lineWidth: strikeWidth )
//                        .foregroundColor(passwordChecker.valid ? Color.black : Color.red))


        }

    }
    
}

//
// MARK: -
// MARK: FIRST TIME PASSWORD
//

extension LoginView {
    
        func passwordChooseInput() -> some View {
            
            VStack(alignment: .leading) {
                SecureFieldWithValidator( title:"write password",
                                          value:$password,
                                          checker:$passwordChecker ) { v in
                        if( v.isEmpty ) {
                            return "password cannot be empty! ☹️"
                        }
                                                                
                        return nil
                }
                .autocapitalization(.none)
                .multilineTextAlignment(.center)
                .padding( 20.0 )
    //            .overlay( RoundedRectangle(cornerRadius: 10)
    //                        .stroke(lineWidth: strikeWidth )
    //                        .foregroundColor(passwordChecker.valid ? Color.black : Color.red))


            }
        }

        func passwordConfirmInput() -> some View {
            
            VStack(alignment: .leading) {
                SecureFieldWithValidator( title: "confirm password",
                                          value:$confirmPassword,
                                          checker:$confirmPasswordChecker ) { v in
                        if( v.isEmpty ) {
                            return "password cannot be empty! ☹️"
                        }
                        if( self.password.compare(v) != .orderedSame) {
                            return "password doesn't match! 🤔"
                        }
                        return nil
                }
                .autocapitalization(.none)
                .multilineTextAlignment(.center)
                .padding( 30.0 )
    //            .overlay( RoundedRectangle(cornerRadius: 10)
    //                        .stroke(lineWidth: strikeWidth )
    //                        .foregroundColor(confirmPasswordChecker.valid ? Color.black : Color.red))

                

            }
    }
}

//
// MARK: -
// MARK: BIOMETRIC AUTHC
//

extension LoginView {
    
    private var isBiometricAvailable:Bool {
        var error: NSError?
        
        let support =  context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return support

    }
    
    private func authenticateWithBiometric() {
        
        var error: NSError?
        
        if( context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            
            let reason = "We need to unlock application"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.dismiss()
                    }
                    else {
                        logger.warning( "error authenticate using biometric \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
        else {
            // NO BIOMETRICS AVAILABLE
        }
    }
    
}

//
// MARK: -
// MARK: PASSWORD AUTHC
//

extension LoginView {

    private func getPassword() throws -> String? {
        
        do {
            
            if let secret = try userPreferencesKeychain.getSecret(forKey: "password" ) {
                return secret.password
            }
            
        }
        catch {
            logger.warning(
                """
                ERROR: getting element 'password'' from keychain.
                \(error.localizedDescription)
                """ )
        }
        return nil

    }

    private func savePasswordAndDismiss() {
        
        do {
            try userPreferencesKeychain.setSecret(forKey: "password",
                                                  secret: (  password:password, note: "keychainx user password" ))
        }
        catch {
            logger.warning(
                """
                ERROR: setting 'password' to keychain.
                \(error.localizedDescription)
                """ )
        }

        dismiss()
    }
    var isPasswordHasBeenInserted:Bool {
        let result = try? getPassword()
        return result != nil
    }
    
    private func submitPassword() {
        #if targetEnvironment(simulator)
          // Simulator!
            dismiss()
        #else
            if( passwordChecker.valid ) {
                dismiss()
            }
        #endif
    }


}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
