//
//  MainPageViewController.swift
//  Temple Flashcards
//
//  Created by Michael Perry on 10/26/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tblViewTemple: UITableView!
    @IBOutlet weak var clctnViewTempleCards: UICollectionView!
    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    
    @IBOutlet weak var lblCorrectCount: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblMatchResult: UILabel!
    
    @IBOutlet weak var viewForBottomBorder: UIView!
    
    @IBOutlet weak var constraintTableViewWidth: NSLayoutConstraint!
    
    //These represent the collection and tableview cells
    //that are currently selected. These are used for matching
    //names of temples.
    var highlightedCollectionCellIndexPath = NSIndexPath()
    var highlightedTableViewTempleIndexPath = NSIndexPath()
    
    var studyMode = false
    
    //Two lists of temples are used and shuffled. One of the 
    //temple lists represents the temples in the tableview and
    //the other list represents the temples in the colelctionview
    var templesCollection = Temple.temples.shuffle()
    var templesTable = Temple.temples.shuffle()
    
    var removedTableCells = [NSIndexPath]()
    var removedCollectionCells = [NSIndexPath]()
    
    var selectedCell = -1
    
    var correctCount: Int = 0 {
        didSet {
            lblCorrectCount.text = "Correct: \(correctCount)"
        }
    }
    
    var incorrectCount: Int = 0 {
        didSet {
            lblIncorrect.text = "Incorrect: \(incorrectCount)"
        }
    }
    
    //When the user refreshes the view the controls on the
    //veiw reset and the temples are shuffled again and
    //animated in the view as the table and collection reload.
    @IBAction func btnRefresh_Clicked(sender: AnyObject) {
        resetView()
        
        self.view.layoutIfNeeded()
        templesCollection = Temple.temples.shuffle()
        templesTable = Temple.temples.shuffle()
        
        UIView.animateWithDuration(0.5, delay: 0, options: .TransitionCrossDissolve, animations: {
            
            self.clctnViewTempleCards.reloadData()
            self.tblViewTemple.reloadData()
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    @IBAction func btnStudy_Clicked(sender: UIBarButtonItem) {
        self.view.layoutIfNeeded()
        
        studyMode = !studyMode
        
        //change the width of the tableview
        constraintTableViewWidth.constant = studyMode ? 0 : 217
        
        //shuffle lists again to get full list of temples again
        //in random order for the study mode view.
        templesCollection = Temple.temples.shuffle()
        templesTable = Temple.temples.shuffle()
        
        self.btnRefresh.enabled = self.studyMode ? false : true
        
        UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseInOut, animations: {
            
            sender.title = self.studyMode ? "Match Mode" : "Study Mode"

            self.clctnViewTempleCards.reloadData()
            
            self.view.layoutIfNeeded()
            
            }, completion: { (Bool) in
                if !self.studyMode {
                    self.tblViewTemple.reloadData()
                }
                self.resetView()
            })
        highlightedCollectionCellIndexPath = NSIndexPath()
        highlightedTableViewTempleIndexPath = NSIndexPath()
    }
    
    //When the subviews get laid out the app checks a view on the top of the 
    //program that holds the scores and title. It takes the dimensions of that
    //view and adds a bottom border to it.
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: viewForBottomBorder.frame.size.height - width, width:  viewForBottomBorder.frame.size.width, height: viewForBottomBorder.frame.size.height)
        border.borderWidth = width
        
        viewForBottomBorder.layer.addSublayer(border)
        viewForBottomBorder.layer.masksToBounds = true
    }
    
    func resetView () {
        if studyMode {
            lblMatchResult.text = "Study Mode"
            lblCorrectCount.text = ""
            lblIncorrect.text = ""
        } else {
            lblMatchResult.text = "Match Mode"
            correctCount = 0
            incorrectCount = 0
        }
        
        selectedCell = -1
        lblMatchResult.layer.shadowRadius = 0.0;
    }
    
    //The indexpath in passed into match() so the temple that was highlighted before
    //a match occurs can be deselected. Otherwise the temple that replaces the matched
    //temple's index would stay highlighted when a match occurs.
    func match (indexPath: Int = -1) {
        self.view.layoutIfNeeded()
        //This double checks that both the collectionview and tableview currently have something highlighted
        if highlightedTableViewTempleIndexPath != NSIndexPath() && highlightedCollectionCellIndexPath != NSIndexPath() {
            if let collectionViewCell = clctnViewTempleCards.cellForItemAtIndexPath(highlightedCollectionCellIndexPath) as? CardCollectionViewCell {
                if let tableViewCell = tblViewTemple.cellForRowAtIndexPath(highlightedTableViewTempleIndexPath) as? TempleTableViewCell {
                    //compare the names of the temples to check for a match
                    if collectionViewCell.lblLabel.text == tableViewCell.lblTempleName.text {
                        correctCount++
                
                        self.lblMatchResult.text = "Correct"
                        lblMatchResult.layer.shadowColor = UIColor.greenColor().CGColor;
                        lblMatchResult.layer.shadowRadius = 4.0;
                        lblMatchResult.layer.shadowOpacity = 0.9;
                        lblMatchResult.layer.shadowOffset = CGSizeZero;
                        lblMatchResult.layer.masksToBounds = false;
                        
                        //update tableview
                        tblViewTemple.beginUpdates()
                        //delete tableview cell
                        tblViewTemple.deleteRowsAtIndexPaths([highlightedTableViewTempleIndexPath], withRowAnimation: .Automatic)
                        //remove corresponding temple item from tableview list
                        templesTable.removeAtIndex(highlightedTableViewTempleIndexPath.row)
                        
                        tblViewTemple.endUpdates()
                        
                        //remove temple from collection
                        templesCollection.removeAtIndex(highlightedCollectionCellIndexPath.row)
                        clctnViewTempleCards.deleteItemsAtIndexPaths([highlightedCollectionCellIndexPath])
                        
                        //since there was a match we need to remove those indexpaths
                        highlightedCollectionCellIndexPath = NSIndexPath()
                        highlightedTableViewTempleIndexPath = NSIndexPath()
                        
                        selectedCell = indexPath
                    } else {
                        incorrectCount++
                        
                        lblMatchResult.text = "Incorrect"
                        lblMatchResult.layer.shadowColor = UIColor.redColor().CGColor;
                        lblMatchResult.layer.shadowRadius = 6.0;
                        lblMatchResult.layer.shadowOpacity = 1;
                        lblMatchResult.layer.shadowOffset = CGSizeZero;
                        lblMatchResult.layer.masksToBounds = false;
                        
                        //this code shakes the screen when the user gets the wrong answer
                        let anim = CAKeyframeAnimation(keyPath: "transform")
                        anim.values = [
                            NSValue(CATransform3D: CATransform3DMakeTranslation(-5,0,0)),
                            NSValue(CATransform3D: CATransform3DMakeTranslation(5,0,0))
                        ]
                        anim.autoreverses = true
                        anim.repeatCount = 2
                        anim.duration = 7/100
                        view.layer.addAnimation(anim, forKey: nil)
                    }
                }
            }
        }
    }

    //TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("TempleHeaderCell") as! TempleTableViewCell
        headerCell.lblTempleName.text = "Temple Names"
        return headerCell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.templesTable.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblViewTemple.dequeueReusableCellWithIdentifier("TempleListingCell", forIndexPath: indexPath) as! TempleTableViewCell
        cell.lblTempleName.text = self.templesTable[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        highlightedTableViewTempleIndexPath = indexPath
        if highlightedTableViewTempleIndexPath != NSIndexPath() && highlightedCollectionCellIndexPath != NSIndexPath() && selectedCell != -1 {
            match()
        }
    }
    
    //CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.templesCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //This deselects the currently highlighted cell. This is so that when a table cell is highlighted first
        //then matches with the collection it will deselect the collection cell that is already highlighted.
        let firstSelectedPath = NSIndexPath(forRow: selectedCell, inSection: 0)
        if let thisTempleCell = clctnViewTempleCards.cellForItemAtIndexPath(firstSelectedPath) as? CardCollectionViewCell {
            thisTempleCell.viewImage.selected = false
            thisTempleCell.viewImage.setNeedsDisplay()
        }
        
        highlightedCollectionCellIndexPath = indexPath
        
        //pass the indexpath row so that that row can be deselected if there is a match
        if highlightedTableViewTempleIndexPath != NSIndexPath() && highlightedCollectionCellIndexPath != NSIndexPath() && selectedCell != indexPath.row {
            match(indexPath.row)
        }
        
        //grab current selected path
        let selectedPath = NSIndexPath(forRow: selectedCell, inSection: 0)
        
        //reset currently selected cell
        if let selectedTempleCell = clctnViewTempleCards.cellForItemAtIndexPath(selectedPath) as? CardCollectionViewCell {
            selectedTempleCell.viewImage.selected = false
            selectedTempleCell.viewImage.setNeedsDisplay()
            selectedCell = -1
        }
        
        //if the same cell is selected twice then reselect and deselect that cell
        if let cell = clctnViewTempleCards.cellForItemAtIndexPath(indexPath) as? CardCollectionViewCell {
            if selectedPath.row != indexPath.row {
                selectedCell = indexPath.row
                cell.viewImage.selected = true
                cell.viewImage.setNeedsDisplay()
            }
        }
    }
    
    //size size for each cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let templeName: NSString = self.templesCollection[indexPath.row].fileName
        let image = UIImage(named: templeName.stringByDeletingPathExtension)
        
        if let size = image?.size {
            let h = size.height
            let w = size.width
            
            let widthRatio = w / h
            let finalSize = CGSize(width: 125*widthRatio, height: 125)
            
            return finalSize
        }
        
        return CGSize(width: 100.0, height: 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("templeCardCell", forIndexPath: indexPath) as! CardCollectionViewCell
        
        cell.viewImage.selected = indexPath.row == selectedCell
        
        cell.viewImage.filename = self.templesCollection[indexPath.row].fileName
        cell.viewImage.name = self.templesCollection[indexPath.row].name
        cell.viewImage.setNeedsDisplay()
        
        cell.lblLabel.text = self.templesCollection[indexPath.row].name
        if !studyMode {
            cell.userInteractionEnabled = true
            cell.lblLabel.hidden = true
            cell.viewLabelShadow.hidden = true
        } else {
            cell.userInteractionEnabled = false
            cell.lblLabel.hidden = false
            cell.viewLabelShadow.hidden = false
            cell.viewImage.layer.zPosition = 1
            cell.lblLabel.layer.zPosition = 3
            cell.viewLabelShadow.layer.zPosition = 2
        }
        
        return cell
    }
}











