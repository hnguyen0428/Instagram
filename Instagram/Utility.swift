//
//  Utility.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    static func closer(to: CGFloat, other: CGFloat, input: CGFloat) -> Bool {
        return self.abs(input - to) < self.abs(input - other)
    }
    
    static func abs(_ input: CGFloat) -> CGFloat {
        let result = input < 0 ? -input: input
        return result
    }
    
    static func withinRange(input: CGFloat, low: CGFloat, high: CGFloat) -> Bool {
        return input > low && input < high
    }
}
