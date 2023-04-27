//
//  Extensions.swift
//  Study-CoreML-SwiftUI
//
//  Created by ShafiulAlam-00058 on 4/3/23.
//

import SwiftUI

extension NSImage {
    func ciImage() -> CIImage? {
        guard let data = self.tiffRepresentation,
              let bitMap = NSBitmapImageRep(data: data) else {
            return nil
        }
        let ci = CIImage(bitmapImageRep: bitMap)
        return ci
    }
}
