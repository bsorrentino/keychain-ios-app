//
//  KeyItemListViewController.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/07/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//



import Foundation
import UIKit
import SwiftUI
import CoreData



// MARK: SwiftUI Bidge
struct KeyItemList_IOS14: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = KeyItemListViewController

    @Environment(\.managedObjectContext) var managedObjectContext

    @Binding var isSearching:Bool
    var geometry:CGSize;
    var provideFormOnSelection:FormSupplierType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<KeyItemList_IOS14>) -> UIViewControllerType
    {
        //logger.trace( "makeUIViewController" )
        
        let controller =
            KeyItemListViewController(context: managedObjectContext, isSearching: $isSearching, provideFormOnSelection:provideFormOnSelection )
        
        controller.geometry = geometry
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<KeyItemList_IOS14>) {
        
        //logger.trace( "updateUIViewController" )
        
        uiViewController.reloadData()
    }
}


// MARK: UIKIT

class KeyItemListViewController : KeyBaseListViewController, UITableViewDataSource {
    
    typealias Values = (sections:[String]?, values:[String:[KeyEntity]])
    
    private var resultSearchController:UISearchController?
    
    private var keys:Values?
    
    private let searchController = UISearchController(searchResultsController: nil)

    private var didSelectWhileSearchWasActive = false
    
    private var isSearching: Binding<Bool>

    var geometry:CGSize = CGSize()
    
    init( context:NSManagedObjectContext, isSearching: Binding<Bool>, provideFormOnSelection:@escaping FormSupplierType ) {
        
        self.isSearching = isSearching

        super.init( context:context, style: .grouped, provideFormOnSelection:provideFormOnSelection )
        
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        
        reloadDataFromManagedObjectContext( with: searchPredicate() )
    }

    override func viewDidLoad() {

       super.viewDidLoad()

        tableView.register(UINib(nibName: "KeyItemCell", bundle: nil), forCellReuseIdentifier: "keyitem")
        tableView.register(UINib(nibName: "KeyGroupCell", bundle: nil), forCellReuseIdentifier: "keygroup")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false   
        // Search Bar
        searchController.searchBar.placeholder = "search keys"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = tableView.backgroundColor
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        resultSearchController = searchController
        
        view.addSubview(searchController.searchBar)
        //self.tableView.tableHeaderView = searchController.searchBar
        
        // Update contentInset to have a right scrolling
//        let searchBarHeight = searchController.searchBar.frame.size.height
//        let tabViewHeight = tableView.frame.height - geometry.height - searchBarHeight
//        let contentInset = UIEdgeInsets(
//            top: searchBarHeight,
//            left: 0,
//            bottom: tabViewHeight,
//            right: 0
//        )
//
//        super.applyContentInsets(contentInset)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if didSelectWhileSearchWasActive {
            searchController.isActive = true
        }
        
    }
        
    //
    // MARK: DATA SOURCE
    //

    private func valuesFromSection( _ section: Int ) -> [KeyEntity]? {
        if let v = keys?.sections?[section] {
            return keys?.values[v]
        }
        
        return keys?.values.first?.value
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return keys?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valuesFromSection(section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys?.sections?[section]
    }
    
    // MARK: Indexed
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return keys?.sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //logger.trace( "item at indexpath \(indexPath.row)" )
                
        guard let items = valuesFromSection(indexPath.section) else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]

        if( item.isGroup() ) {

            guard let group = tableView.dequeueReusableCell(withIdentifier: "keygroup", for: indexPath) as? GroupTableViewCell else {
                
                return UITableViewCell()
            }

            group.title.text = item.mnemonic.uppercased()
            
            return group

        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyitem", for: indexPath)
        
        cell.textLabel?.text = item.mnemonic.uppercased()
        cell.detailTextLabel?.text = item.isGrouped() ? item.groupPrefix ?? "" : item.username
        
        return cell
        
    }
    
     
    //
    // MARK: TAP ACTIONS
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let keys = valuesFromSection(indexPath.section) else {
            return
        }
        
        let selectedItem = keys[indexPath.row]
        
        if( selectedItem.isGroup() ) {

            let tabViewHeight = tableView.frame.height - geometry.height
            let contentInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: tabViewHeight,
                right: 0
            )

            let newViewController = KeyGroupListView( selectedGroup: selectedItem, contentInsets: contentInsets, provideFormOnSelection:provideFormOnSelection )
            self.navigationController?.pushViewController( UIHostingController(rootView: newViewController), animated: true)

        }
        else {

            let selectedItemForm = self.provideFormOnSelection( selectedItem )
            
            self.navigationController?.pushViewController( UIHostingController(rootView: selectedItemForm), animated: true)

            if searchController.isActive {
                didSelectWhileSearchWasActive = true
                searchController.dismiss(animated: false )
            }
        }

    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let keys = valuesFromSection(indexPath.section) else {
            return
        }
        
        let selectedItem = keys[indexPath.row]
        
        let selectedItemForm = self.provideFormOnSelection( selectedItem )
        
        self.navigationController?.pushViewController( UIHostingController(rootView: selectedItemForm), animated: true)
        
    }
    
    
    //
    // MARK: SWIPE ACTIONS
    //
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copy = UIContextualAction( style: .normal, title: "Copy" ) { action, view, completionHandler in
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [ copy ])
        
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let keys = valuesFromSection(indexPath.section) else {
            return nil
        }

        let selectedItem = keys[indexPath.row]


        let delete = UIContextualAction( style: .destructive, title: "Delete" ) { action, view, completionHandler in
            self.performDelete(item: selectedItem, completionHandler: completionHandler)
            
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        
        return configuration
    }
    
    
}

// MARK: Search Extension
extension KeyItemListViewController : UISearchResultsUpdating, UISearchBarDelegate  {
  
    // create the Predicate coherent with UI state
    func searchPredicate() -> NSPredicate? {
        
        if searchController.isActive , let searchText = searchController.searchBar.text, !searchText.isEmpty {
            
            let search_criteria = "mnemonic CONTAINS[c] %@ OR groupPrefix CONTAINS[c] %@"

            return NSPredicate(format: search_criteria, searchText, searchText)
        }
        
        return nil

    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        logger.trace( "updateSearchResults\nisActive:\(searchController.isActive)\nisFiltering:\(self.isFiltering)" )
        
        reloadDataFromManagedObjectContext( with: searchPredicate() )
        
        self.isSearching.wrappedValue = searchController.isActive
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.didSelectWhileSearchWasActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.didSelectWhileSearchWasActive = false

    }

}

// MARK: Core Data Extension
extension KeyItemListViewController  {
    
    
    func reloadDataFromManagedObjectContext( with predicate:NSPredicate? )  {
        
        // No reload is required because we are coming back from detail screen
        guard !didSelectWhileSearchWasActive else {
            return
        }
        
        let request:NSFetchRequest<KeyEntity> = KeyEntity.fetchRequest()

        let sortOrder = NSSortDescriptor(keyPath: \KeyEntity.mnemonic, ascending: true)
        
        request.sortDescriptors = [sortOrder]
        
        let not_grouped = NSCompoundPredicate( notPredicateWithSubpredicate: NSPredicate( format: "group != nil AND group == YES"))

        if let p = predicate { // FILTER ACTIVE

            let group = NSCompoundPredicate( type: .and, subpredicates: [ NSPredicate( format: "groupPrefix != nil "), not_grouped ])

            request.predicate = NSCompoundPredicate( type: .and, subpredicates: [ NSCompoundPredicate( notPredicateWithSubpredicate: group), p] )
        }
        else { // FILTER NOT ACTIVE
            request.predicate = not_grouped
        }

        do {
            
            let result = try self.managedObjectContext.fetch(request)
         
            if( predicate == nil ) {

                var sectionMap = [String:[KeyEntity]]()
                
                for key in result {
                    let prefix = String(key.mnemonic.prefix(1))
                    
                    if var values = sectionMap[prefix]  {
                        values.append( key )
                        sectionMap[prefix] = values
                    }
                    else {
                        sectionMap[prefix] = [key]
                    }
                    
                 }
                 
                self.keys = ( sections:sectionMap.keys.sorted().map( { v in v.uppercased() }  ), values:sectionMap )

            } else {
                self.keys = ( nil, values:["all":result])
            }
        }
        catch {
            logger.warning( "error fetching keys \(error.localizedDescription)" )
            self.keys = nil
        }

        tableView.reloadData()
    }
    
}


