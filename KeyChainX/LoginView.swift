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
            .padding()
            .border( passwordChecker.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            

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
            .padding()
            .border( passwordChecker.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            

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
            .padding()
            .border( confirmPasswordChecker.valid ? Color.clear : Color.red )
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .autocapitalization(.none)
            

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
