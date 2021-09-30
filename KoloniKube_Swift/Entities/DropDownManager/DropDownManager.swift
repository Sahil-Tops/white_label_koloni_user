//
//  DropDownManager.swift
//  DropDown
//
//  Created by Tops on 12/14/16.
//  Copyright © 2016 Kevin Hirsch. All rights reserved.
//

import UIKit
import DropDown
protocol DropDownDelegate {
    func didSelectItemAtIndexPathInDropDown(Index:Int, Title:String, onDropdown: DropDown)
}

class DropDownManager: NSObject {
    
    //MARK: - DropDown's
    //You can define more dropdown if you want:
    
    var Delegate:DropDownDelegate!
    let chooseArticleDropDown = DropDown()
    let amountDropDown = DropDown()
    let chooseDropDown = DropDown()
    let centeredDropDown = DropDown()
    let rightBarDropDown = DropDown()
    let Tag = 0
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseArticleDropDown,
            self.amountDropDown,
            self.chooseDropDown,
            self.centeredDropDown,
            self.rightBarDropDown
        ]
    }()
    
    func setDismissMode(Mode: DropDown.DismissMode){
        dropDowns.forEach { $0.dismissMode = Mode }
    }
    
    func setDirection(Direction: DropDown.Direction) {
        dropDowns.forEach { $0.direction = Direction }
    }
    
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 40
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        //appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.selectionBackgroundColor = UIColor.clear
        //appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 3
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        appearance.textFont = UIFont(name: "Georgia", size: 13)!
        dropDowns[0].cellNib = UINib(nibName: "MyCell", bundle: nil)
        
        
        dropDowns[0].customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                            guard let cell = cell as? MyCell else { return }
            
                            // Setup your custom UI components
                            cell.suffixLabel.text = "Suffix \(index)"
                        }
//        dropDowns.forEach {
//            /*** FOR CUSTOM CELLS ***/
//            $0.cellNib = UINib(nibName: "MyCell", bundle: nil)
//            
//            $0.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
//                guard let cell = cell as? MyCell else { return }
//                
//                // Setup your custom UI components
//                cell.suffixLabel.text = "Suffix \(index)"
//            }
//            /*** ---------------- ***/
//        }
    }

    //MARK: DATASOURCE AND DELEGATE FOR ALLDROPDOWN
    func setupChooseArticleDropDownOnAnyObject(OnObject: UIView, DataSourse:[String]) {
        chooseArticleDropDown.anchorView = OnObject
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: OnObject.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseArticleDropDown.dataSource = DataSourse
        
        // Action triggered on selection
        chooseArticleDropDown.selectionAction = { [unowned self] (index, item) in
            self.dropDowns[0].tag = self.amountDropDown.tag
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[0])
        }
    }

    func setupChooseArticleDropDown(onButton: UIButton, DataSourse:[String]) {
        chooseArticleDropDown.anchorView = onButton
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: onButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseArticleDropDown.dataSource = DataSourse
        
        // Action triggered on selection
        chooseArticleDropDown.selectionAction = { [unowned self] (index, item) in
            
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[0])
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }
    func setupAmountDropDownOnUiview(onButton:UIView, DataSourse:[String]) {
        amountDropDown.anchorView = onButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        amountDropDown.bottomOffset = CGPoint(x: 0, y: onButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        amountDropDown.dataSource = DataSourse
        
        // Action triggered on selection
        amountDropDown.selectionAction = { [unowned self] (index, item) in
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[1])
        }
    }
    
    func setupAmountDropDown(onButton:UIButton, DataSourse:[String]) {
        amountDropDown.anchorView = onButton
    
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        amountDropDown.bottomOffset = CGPoint(x: 0, y: onButton.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        amountDropDown.dataSource = DataSourse
        
        // Action triggered on selection
        amountDropDown.selectionAction = { [unowned self] (index, item) in
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[1])
        }
    }
    
    
    
    func setupChooseDropDown(onButton: UIButton, DataSourse:[String]) {
        chooseDropDown.anchorView = onButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDropDown.bottomOffset = CGPoint(x: 0, y: onButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.dataSource = DataSourse
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [unowned self] (index, item) in
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[2])
        }
    }
    
    func setupCenteredDropDown(onButton: UIButton, DataSourse:[String]) {
        // Not setting the anchor view makes the drop down centered on screen
        //		centeredDropDown.anchorView = centeredDropDownButton
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        centeredDropDown.dataSource = DataSourse
        centeredDropDown.bottomOffset = CGPoint(x: 0, y: onButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        
        
        // Action triggered on selection
        centeredDropDown.selectionAction = { [unowned self] (index, item) in
            self.Delegate.didSelectItemAtIndexPathInDropDown(Index: index, Title: item, onDropdown: self.dropDowns[2])
        }
    }
    
    func setupRightBarDropDown(onButton:UIButton, DataSourse:[String]) {
        rightBarDropDown.anchorView = onButton
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        rightBarDropDown.dataSource = DataSourse
    }
}
