//
//  ColorSections.swift
//  Pairs_
//
//  Created by Елизавета on 17.04.2020.
//  Copyright © 2020 Elizaveta. All rights reserved.
//

import Foundation
import UIKit

struct ColorSection: Decodable, Hashable {
    let title: String
    var items: [ColorItem]
}
