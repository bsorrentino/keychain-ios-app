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


struct LoginView: View {
    @Environment(\.presentationMode) private var isPresented
    @Environment(\.UserPreferencesKeychain) private var userPreferencesKeychain

    @State var password:String = ""
    @State var passwordChecker   = FieldChecker()

    @State var confirmPassword:String = ""
    @State var confirmPasswordChecker   = FieldChecker()

    //@State private var showingAlert = false
    //@State private var authenticationError:String = ""
    
    private let strikeWidth:CGFloat = 0.5
    
    private var  context = LAContext()

    private var isBiometricAvailable:Bool {
        var error: NSError?
        
        let support =  context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return support

    }
    
    private func authenticate() {
        
        var error: NSError?
        
        if( context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            
            let reason = "We need to unlock application"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.dismiss()
                    }
                    else {
                        print( "error authenticate using biometric \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
        else {
            // NO BIOMETRICS AVAILABLE
        }
    }
    private func getPassword() throws -> String? {
        
        do {
            
            if let password = try userPreferencesKeychain.getString( "password" ) {
                return password
            }
            
        }
        catch {
            print( "ERROR: getting element 'password'' from keychain.\n\(error)" )
        }
        return nil

    }

    private func dismiss() {
        self.isPresented.wrappedValue.dismiss()
    }
    
    private func submit() {
        #if targetEnvironment(simulator)
          // Simulator!
            dismiss()
        #else
            if( passwordChecker.valid ) {
                dismiss()
            }
        #endif
    }

    private func savePasswordAndDismiss() {
        
        do {
            try userPreferencesKeychain
                .comment("keychainx user password")
                .set( password, key: "password" )
        }
        catch {
            print( "ERROR: setting 'password' to keychain.\n\(error)" )
        }

        dismiss()
    }

    var isPasswordHasBeenInserted:Bool {
        let result = try? getPassword()
        return result != nil
    }
    
    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            SecureFieldWithValidator(
                title:"give me password",
                value:$password,
                checker:$passwordChecker,
                onCommit: submit)   { v in
                    
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    
                    do {
                        guard let password = try self.getPassword() else {
                            return "password doesn't exist!"
                        }
                        
                        if( password.compare(v) != .orderedSame) {
                            return "password doesn't match!"
                        }
                    }
                    catch {
                        
                        return error.localizedDescription
                    }
                                        
                    return nil
            }
            .autocapitalization(.none)
            .padding( 10.0 )
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth )
                    .foregroundColor(passwordChecker.valid ? Color.black : Color.red))


        }

    }
    
    func passwordInput1() -> some View {
        
        VStack(alignment: .leading) {
            SecureFieldWithValidator( title:"write password",
                                      value:$password,
                                      checker:$passwordChecker ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                                                            
                    return nil
            }
            .autocapitalization(.none)
            .padding( 10.0 )
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth )
                    .foregroundColor(passwordChecker.valid ? Color.black : Color.red))


        }
    }

    func passwordInput2() -> some View {
        
        VStack(alignment: .leading) {
            SecureFieldWithValidator( title: "cofirm password",
                                      value:$confirmPassword,
                                      checker:$confirmPasswordChecker ) { v in
                    if( v.isEmpty ) {
                        return "password cannot be empty"
                    }
                    if( self.password.compare(v) != .orderedSame) {
                        return "password doesn't match!"
                    }
                    return nil
            }
            .autocapitalization(.none)
            .padding( 10.0 )
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: strikeWidth )
                    .foregroundColor(confirmPasswordChecker.valid ? Color.black : Color.red))

            

        }

    }

    private func checkError( with:FieldChecker ) -> some View {
        
        Text( with.errorMessage ?? "" )
            .fontWeight(.light)
            .font(.footnote)
            .foregroundColor(Color.red)
            .padding(.leading, 10)

    }


    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                if isBiometricAvailable {
                   
                    Button( action: {
                        self.authenticate()
                    }) {
                         VStack {
                            Image( systemName: "faceid" )
                                .resizable()
                                .frame(width: 100.0, height: 100.0, alignment: .center)
                            Text( "Use FaceID for authenticate")
                        }
                    }
//                    .alert(isPresented: $showingAlert) {
//                        Alert(  title: Text("Autheticazione Failed"),
//                                message: Text(authenticationError),
//                                dismissButton: .default(Text("Got it!")))
//                    }
                    
                }
                else {
                if isPasswordHasBeenInserted {

                    HStack(alignment: .center, spacing: 10) {
                        passwordInput()
                        Button( action: dismiss ){
                            Text("Accept")
                        }
                        .disabled( !passwordChecker.valid )
                    }
                    checkError( with: passwordChecker )
                    
                }
                else {

                    passwordInput1()
                    checkError( with: passwordChecker )
                    passwordInput2()
                    checkError( with: confirmPasswordChecker )
                    
                    HStack {
                        Spacer()
                        Button( action: savePasswordAndDismiss ){
                            Text("Accept")
                        }
                        .disabled( !(passwordChecker.valid && confirmPasswordChecker.valid) )
                    }.padding(.top, 10)
                }
                }

                
            }.padding( EdgeInsets( top:0, leading:10, bottom:0, trailing:10  ))
            
                    
            }.navigationBarTitle( Text("Login"), displayMode: .large)
        }
        
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
