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

struct GroupField : View {
    
    @Binding var value:String?

    var body: some View {
        NavigationLink( destination: GroupList( value: $value) ) {
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

    
}


struct GroupList: View {
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var value:String?
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest( fetchRequest:KeyEntity.fetchGroups() )
    var groups:FetchedResults<KeyEntity>
    
    @StateObject var groupValid = FieldChecker2<String>()
    @State var newGroup:String = ""

    private var selectableGroups: [KeyEntity] {
        groups.filter { e -> Bool in
            guard let prefix = e.groupPrefix else { return false }
            return prefix != value
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
                    ForEach( selectableGroups, id: \KeyEntity.self ) { (group:KeyEntity) in
                        Text( group.mnemonic )
                            .font( .body ).onTapGesture(perform: {
                                self.value = group.groupPrefix!
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
        let _ = KeyEntity.createGroup(context: self.context, groupPrefix: self.newGroup)
        
        do {
            try self.context.save()
        }
        catch {
            logger.warning( """
                error inserting new group
                
                \(error.localizedDescription)
                """ )

        }
        
        self.newGroup = ""
    }

    func delete( at offsets: IndexSet ) {
        if let first = offsets.first {
            let selectGroup = groups[ first ]
            
            context.delete(selectGroup)

            do {
                try self.context.save()
            }
            catch {
                logger.warning( """
                    error deleting new group
                    
                    \(error.localizedDescription)
                    """ )

            }
        }
    }
        
}



#if DEBUG
struct KeyItemForm_Group_Previews: PreviewProvider {
    static var previews: some View {
        // https://stackoverflow.com/questions/57700304/previewing-contentview-with-coredata
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        return Group() {
                
                GroupField(value:.constant("") )
                //GroupList( value:.constant("") )
            
                }.environment(\.managedObjectContext, context)
    }
}
#endif

