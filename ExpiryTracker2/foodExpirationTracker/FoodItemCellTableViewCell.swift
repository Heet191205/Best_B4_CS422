//
//  FoodItemCellTableViewCell.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/8/25.
//

import UIKit


class FoodItemCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productCategory: UILabel!
    
    @IBOutlet weak var productExpirationDate: UILabel!
    @IBOutlet weak var productExpirationStatus: UILabel!
    
    
    @IBOutlet weak var productQuantity: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        productExpirationStatus.layer.cornerRadius = 5
        productExpirationStatus.clipsToBounds = true
        productExpirationStatus.textAlignment = .center
        
    }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

   
}

    
}
