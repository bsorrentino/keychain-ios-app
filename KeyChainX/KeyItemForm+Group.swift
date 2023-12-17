//
//  KeyItemForm+Group.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 22/12/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI
import FieldValidatorLibrary
import Shared
import SwiftData

struct GroupField : View {
    
    var value:String?

    var body: some View {
        HStack {
            
            Image( systemName: "folder.fill")
            if( value?.isEmpty ?? true ) {
                Text( "tap to choose section" )
                    .foregroundColor(.gray)
                    .italic()
            }
            else {
                Text( value! )
            }
        }
        .padding(EdgeInsets( top: 20, leading: 0, bottom: 20, trailing: 0))
    }
}


struct GroupList: View {
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var field:String?
    @Environment(\.modelContext) var context
    
    @Query( KeyInfo.fetchGroups() )
    var groups: [KeyInfo]
    
    @StateObject var groupValid = FieldChecker2<String>()
    @State var newGroup:String = ""

    private var selectableGroups: [KeyInfo] {
        groups.filter { e in
            guard let prefix = e.groupPrefix else { return false }
            return prefix != field
        }
    }
    var body: some View {
        
        List {
            Section(header: Text("New Group")) {
                
                HStack {
                    TextField( "insert group", text: $newGroup.onValidate( checker: groupValid ) { v in
                           
                            if( v.isEmpty ) {
                               return "group name cannot be empty !"
                            }
                           
                           return nil
                    })
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.body)
                    
                    addButton()
                }
                
            }
            .font( .headline )
            
            
            Section(header: Text("Group(s)")) {
                ForEach( selectableGroups, id: \KeyInfo.self ) { (group:KeyInfo) in
                    Text( group.mnemonic )
                        .font( .body ).onTapGesture(perform: {
                            self.field = group.groupPrefix!
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    
                }
                .onDelete( perform: delete)
            

            }
            .font( .headline )
        }
        .navigationBarTitle( Text("group"), displayMode: .inline )
        .navigationBarItems(
             trailing: EditButton())
    
    }
    
    func addButton() -> some View {
        Button( action: {
              self.insert()
          }) {
              Image( systemName: "plus.circle.fill" )
                .foregroundColor( groupValid.valid ? .green : .accentColor)
                  .imageScale(.large)
          }
          .disabled( !groupValid.valid )

     }

    func insert() {
        // 
        let group = KeyInfo.createGroup(groupPrefix: self.newGroup )
        
        self.context.insert( group )
        
        self.newGroup = ""
    }

    func delete( at offsets: IndexSet ) {
        if let first = offsets.first {
            let selectGroup = groups[ first ]
            
            KeyInfo.delete(selectGroup, inContext: context)

        }
    }
        
}

#Preview {
    
    NavigationView {
        GroupField(value:"" )
            .modelContainer( previewContainer )
    }
}

#Preview {
    
    NavigationView {
        GroupField(value:"Group1" )
            .modelContainer( previewContainer )
    }
}


