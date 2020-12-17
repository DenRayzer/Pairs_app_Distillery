//
//  ColorCell.swift
//  Pairs_
//
//  Created by Елизавета on 19.04.2020.
//  Copyright © 2020 Elizaveta. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    static var reuseId: String = "ColorCell"
    var number = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupElements() {
        number.translatesAutoresizingMaskIntoConstraints = false
        number.font = number.font.withSize(30)
        number.textColor = .white
    }
    
    func setupConstraints() {
        addSubview(number)
        number.widthAnchor.constraint(equalToConstant: 50).isActive = true
        number.heightAnchor.constraint(equalToConstant: 50).isActive = true
        number.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
    }
    
}
