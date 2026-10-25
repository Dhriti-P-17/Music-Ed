//
//  SheetMusicScanner.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/16/26.
//

import Foundation
import Vision
import UIKit

class SheetMusicScanner {
    
    func scanImage(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        // 1. Create a request to find horizontal lines (the staff)
        let request = VNDetectRectanglesRequest { request, error in
            guard let observations = request.results as? [VNRectangleObservation] else { return }
            
            for rect in observations {
                // In music, staff lines are long and thin.
                // We filter for rectangles with a very high aspect ratio.
                if rect.boundingBox.width > rect.boundingBox.height * 10 {
                    print("Found a potential staff line at: \(rect.boundingBox.minY)")
                }
            }
        }
        
        // 2. Run the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
