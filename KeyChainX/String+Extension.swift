//
//  String+Extension.swift
//  KeyChainX
//
//  Created by Bartolomeo Sorrentino on 04/01/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation


// Regular Expression extension
extension String {
    
    
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: self) else {
                        return ""
                    }
                    return String(self[range])
                }
            }
        } catch let error {
            // logger.warning("invalid regex: \(error.localizedDescription)")
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

}





