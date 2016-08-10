//
//  TempleCard.swift
//  Temple Flashcards
//
//  Created by Michael Perry on 10/29/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

class TempleCardView: UIView {
    
    var image = UIImage()
    var filename: NSString = ""
    var name = ""
    var selected = false
    
    //draw image in cell
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(rect: self.bounds)
        
        UIColor.whiteColor().setStroke()
        path.lineWidth = 2.0
        path.fill()
        
        let imageName = filename.stringByDeletingPathExtension
        image = UIImage(named: imageName)!
        
        self.alpha = selected ? 0.5 : 1
        
        image.drawInRect(bounds)
        
        path.stroke()
    }
}
