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

    public var isPossibleDropTo: ((target:NSIndexPath) -> Bool)?
    public var isPossiblebeginDrag: ((source:NSIndexPath) -> Bool)?
    public var dropTo: ((source:NSIndexPath, target:NSIndexPath) -> Void)?
    
    private var tableView:UITableView

    private var source:NSIndexPath?
    
    private let viewTag = 99
    
    private var longPressRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    #if USE_PAN
    private var panRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer()
    #endif
    
    private var dragView:UIView? {
        get {
            return self.tableView.viewWithTag(viewTag)
        }
    }
    
    public var enabled:Bool {
        get {
            #if USE_PAN
            return longPressRecognizer.enabled && panRecognizer.enabled
            #else
            return longPressRecognizer.enabled
            #endif
        }
        set(value) {
            longPressRecognizer.enabled = value
            #if USE_PAN
            panRecognizer.enabled = value
            #endif
        }
    }
    
    // MARK:

    init(tableView:UITableView!)  {
        
        self.tableView = tableView
     
        let handleLongPressSelector : Selector = "handleLongPress:"
        self.longPressRecognizer.addTarget(self, action: handleLongPressSelector )
        self.tableView.addGestureRecognizer(self.longPressRecognizer)

        
        #if USE_PAN
        let handlePanSelector : Selector = "handlePan:"
        self.panRecognizer.addTarget(self, action: handlePanSelector )
        self.tableView.addGestureRecognizer(self.panRecognizer)
        #endif
    }

    // MARK:
    // MARK: delegate closures
    
    private func isPossibleBeginDrag( i:NSIndexPath ) -> Bool {
    
        guard let bd = isPossiblebeginDrag  else {
            return true
        }
        
        return bd(source:i)
        
    }
    
    private func isPossibleDropTo( i:NSIndexPath ) -> Bool {
    
        if let s = source {
            if s.compare(i) == .OrderedSame {
                return false;
            }
        }
   
        guard let pdt = isPossibleDropTo else {
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
    
    // MARK:
    // MARK: private methods
    
    private func isTopRow( index:NSIndexPath ) -> Bool {
    
        return index.section == 0 && index.row == 0
    
    }

    private func isLastRow(index:NSIndexPath) -> Bool {
        let sectionsAmount = self.tableView.numberOfSections
        let rowsAmount = self.tableView.numberOfRowsInSection(index.section)
        return index.section == sectionsAmount - 1 && index.row == rowsAmount - 1
        
    }

    private func addDragViewFromCell(cell:UITableViewCell) -> UIView {
        
        UIGraphicsBeginImageContext(cell.bounds.size)
        
        let graficContext = UIGraphicsGetCurrentContext()
        
        cell.layer.renderInContext(graficContext!)
        
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        let newView = UIImageView(image: viewImage)
        
        newView.layer.borderColor = UIColor.blackColor().CGColor
        newView.layer.borderWidth = 2.0
        newView.tag = viewTag;
        
        
        self.tableView.addSubview(newView)
        self.tableView.bringSubviewToFront(newView)
        
        newView.center = cell.center;
        
        UIView.animateWithDuration(0.4,
            delay:0.0,
            options: .CurveLinear,
            animations:{ () -> Void in
                newView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            },
            completion:{ (finished:Bool) -> Void in
            })
        
        return newView;
    
    }
    
    private func removeDragView() -> UIView? {
    
        guard let dragView = self.dragView else {
            return nil
        }
        
        dragView.removeFromSuperview()
        
        return dragView;
    }

    private func cellForRowAtPoint( point:CGPoint) -> UITableViewCell?  {
    
        guard let i = self.tableView.indexPathForRowAtPoint(point) else {
            return nil
        }
        
        return self.tableView.cellForRowAtIndexPath(i)
        
    }
    
    
    private func findTappedCell( recognizer:UIGestureRecognizer ) -> UITableViewCell? {
        
        
        let tPoint = recognizer.locationInView(self.tableView)
        
        let cells = self.tableView.visibleCells
        
        
        for cell in cells {
            
            if (CGRectContainsPoint(cell.frame, tPoint)) {
                return cell;
            }
        }
    
        return nil
    }
    
    private func checkForScrollingUsingVisibleRows( i:NSIndexPath ) -> Bool {
    
        guard let dragView = self.dragView else {
            return false
        }
        
        if self.isTopRow(i) || self.isLastRow(i)  {
            return false
        }
        
        guard let visibleRow = self.tableView.indexPathsForVisibleRows else {
            return false;
        }
        
        if i.compare(visibleRow[0]) == .OrderedSame  {
        
            if let cell = self.tableView.cellForRowAtIndexPath(i) {
            
                var frame = cell.frame;
            
                frame.origin.y -= (frame.size.height + 5);
            
                self.tableView.scrollRectToVisible(frame, animated:true)
                self.tableView.bringSubviewToFront(dragView)
            
                return true;
            }
        }
        else if i.compare(visibleRow[visibleRow.count-1]) == .OrderedSame  {
            
            if let cell = self.tableView.cellForRowAtIndexPath(i) {
            
                var frame = cell.frame;
            
                frame.origin.y += frame.size.height;
            
                self.tableView.scrollRectToVisible(frame, animated:true)
                self.tableView.bringSubviewToFront(dragView)
                
                return true;
            }
        }
        
        return false
    }
  
    private func beginDrag( recognizer:UIGestureRecognizer ) {
        var selectedCell:UITableViewCell?
        
        var selectedIndexPath = self.tableView.indexPathForSelectedRow
        
        if let i = selectedIndexPath  {

            if !self.isPossibleBeginDrag(i) {
                return;
            }
            
            self.tableView.deselectRowAtIndexPath(i, animated:true)
            
            selectedCell = self.tableView.cellForRowAtIndexPath(i)
            
        }
        else {
            
            let tPoint = recognizer.locationInView(self.tableView)
            
            selectedIndexPath = self.tableView.indexPathForRowAtPoint(tPoint)
            
            if let i = selectedIndexPath  {
                
                if !self.isPossibleBeginDrag(i) {
                    return;
                }
                
                selectedCell = self.tableView.cellForRowAtIndexPath(i)
            }
        }
        
        if let i = selectedIndexPath, let cell = selectedCell {
        
            self.source = i

            self.addDragViewFromCell(cell)
        }
        
    
    }
    
    private func moveDrag( recognizer:UIGestureRecognizer ) {
        
        guard let dragView = self.dragView else {
            return
        }
        
        var tPoint = recognizer.locationInView(self.tableView)
        
        if let i = self.tableView.indexPathForRowAtPoint(tPoint) {
            
            if !self.checkForScrollingUsingVisibleRows(i) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void  in
                    
                    if self.isPossibleDropTo(i) {
                        
                        self.tableView.selectRowAtIndexPath(i, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    }
                    
                });
            }
        }
        
        tPoint = recognizer.locationInView(self.tableView)
        
        dragView.center = tPoint;
        
    }
    
    private func endDrag( recognizer:UIGestureRecognizer ) {
        
        guard let dragView = self.dragView else {
            return
        }
        
        
        let tPoint = recognizer.locationInView(self.tableView)
        
        let index:NSIndexPath? = self.tableView.indexPathForRowAtPoint(tPoint)
        
        if let i = index  {
        
            if !self.isPossibleDropTo(i) {
                self.endDrop(nil)
                return
            }
        }
        
        dragView.center = tPoint;
        
        UIView.animateWithDuration(0.4,
            delay:0.0,
            options: .CurveEaseIn,
            animations:{ () -> Void in
                dragView.transform = CGAffineTransformMakeScale(0.2, 0.2);
            },
            completion: {(finished:Bool) -> Void in
                self.endDrop(index)
            })
        
    }
    
    private func endDrop(index:NSIndexPath?) -> Void {
    
        self.removeDragView()
        
        self.source = nil
        
        if let i = index, let s = source  {
            self.performDropTo(s, target:i)
        }
    
    }

    
    // MARK:
    // MARK: GestureRecognizer
    
    @objc public func handleLongPress( sender:UIGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            print("Start Drag Became")
            self.beginDrag(sender)
            break;
        case .Changed:
            print("Start Drag Changed")
            self.moveDrag(sender)
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
            self.source = nil
            break;
        }
        
    }

    #if USE_PAN
    @objc public func handlePan( sender:UIGestureRecognizer ) {
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
    #endif
}