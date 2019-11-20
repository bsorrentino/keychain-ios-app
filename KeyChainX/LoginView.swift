//
//  LoginView.swift
//  keychain
//
//  Created by Bartolomeo Sorrentino on 06/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import Combine
import FieldValidatorLibrary


struct LoginView: View {
    @Environment(\.presentationMode) private var isPresented
    
    @State var password:String = ""
    @State var passwordChecker   = FieldChecker()

    @State var confirmPassword:String = ""
    @State var confirmPasswordChecker   = FieldChecker()

    private let strikeWidth:CGFloat = 0.5
    
    private func getPassword() throws -> String? {
        let result = AppKeychain.shared.getPassword(key: "mypassword");
        return result?.password;
    }

    private func dismiss() {
        self.isPresented.wrappedValue.dismiss()
    }

    private func savePasswordAndDismiss() {
        AppKeychain.shared.setPassword(  key: "mypassword",
                                    password: password )
        dismiss()
    }

    var isPasswordHasBeenInserted:Bool {
        let result = try? getPassword()
        return result != nil
    }
    
    func passwordInput() -> some View {
        
        VStack(alignment: .leading) {
            SecureFieldWithValidator( title:"give me password",
                                      value:$password,
                                      checker:$passwordChecker ) { v in
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
            }.padding( EdgeInsets( top:0, leading:10, bottom:0, trailing:10  ))
            
                    
            }.navigationBarTitle( Text("Login"), displayMode: .large)
        }
        
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
