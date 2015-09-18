//
//  DDTableViewManager.swift
//  keychain2
//
//  Created by Bartolomeo Sorrentino on 18/09/15.
//  Copyright © 2015 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import UIKit

public class DDTableViewManager {

    public var possibleDropTo: ((target:NSIndexPath) -> Bool)?
    public var beginDrag: ((source:NSIndexPath) -> Bool)?
    public var dropTo: ((source:NSIndexPath, target:NSIndexPath) -> Void)?
    
    private var _tableView:UITableView

    private var _source:NSIndexPath?
    
    private var _longPressRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    private var _panRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    init(tableView:UITableView!)  {
        
        self._tableView = tableView
     
        self._longPressRecognizer.addTarget(self, action: "handleLongPress:")
        self._panRecognizer.addTarget(self, action: "handlePan:")
    }

    private func isPossibleBeginDrag( i:NSIndexPath ) -> Bool {
    
        guard let bd = beginDrag  else {
            return true
        }
        
        return bd(source:i)
        
    }
    
    
    private func isPossibleDropTo( i:NSIndexPath ) -> Bool {
    
        if _source != nil && _source == i {
                return false;
        }
   
        guard let pdt = possibleDropTo else {
            return true
        }
        
        return pdt(target: i)
    }
    
    
    private func performDropTo( source:NSIndexPath, target:NSIndexPath ) {

        guard let pdt = dropTo else {
            return
        }

        pdt(source:source, target:target )
    }
    
    private func isTopRow( index:NSIndexPath ) -> Bool {
    
        return index.section == 0 && index.row == 0
    
    }

    private func isLastRow(index:NSIndexPath) -> Bool {
        let sectionsAmount = self._tableView.numberOfSections
        let rowsAmount = self._tableView.numberOfRowsInSection(index.section)
        return index.section == sectionsAmount - 1 && index.row == rowsAmount - 1
        
    }

    func beginDrag( recognizer:UIGestureRecognizer ) {
    
    }
    func endDrag( recognizer:UIGestureRecognizer ) {
        
    }

    func moveDrag( recognizer:UIGestureRecognizer ) {
        
    }

    func handleLongPress( sender:UIGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            print("Start Drag Became")
            self.beginDrag(sender)
            break;
        case .Changed:
            print("Start Drag Changed")
            break;
        case .Ended:
            print("Start Drag Ended")
            self.endDrag(sender)
            break;
        case .Cancelled:
            print("Start Drag Cancelled")
            break;
        case .Possible:
            print("Start Drag Possible")
            break;
        case .Failed:
            print("Start Drag Failed")
            self._source = nil
            break;
        }
        
    }

    func handlePan( sender:UIGestureRecognizer ) {
        switch sender.state {
        case .Began:
            print("Start Drag Became")
            break;
        case .Changed:
            print("Start Drag Changed")
            self.moveDrag(sender)
            break;
        case .Ended:
            print("Start Drag Ended")
            break;
        case .Cancelled:
            print("Start Drag Cancelled")
            break;
        case .Possible:
            print("Start Drag Possible")
            break;
        case .Failed:
            print("Start Drag Failed")
            break;
        }
        
    }
}