//
//  VisionManager.swift
//  Study-CoreML-SwiftUI
//
//  Created by ShafiulAlam-00058 on 3/30/23.
//

import SwiftUI
import Vision
import CoreML
import Cocoa
import AppKit

class VisionManager {
    
    static var shared = VisionManager()
    private init() {}
    
    public var model : VNCoreMLModel!
    
    private var cgImage: CGImage!
    private var ciImage: CIImage!
    private var faceBound: CGRect!
    private var emotion: String = "Not found"
    
    lazy var classificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleEmotionsClassification)
    
    func setupVision() {

        let bundle = Bundle(for: type(of: self))
        
        guard let modelURL = bundle.url(forResource: "fer2013_mini_XCEPTION", withExtension: "mlmodelc") else {
            return
        }
        do {
            self.model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            print("model found!")
        }
        catch {
            print(error)
        }
        
    }

    
    func classifyImage(imageName: String) -> String {
        
        // Convert the Image to a NSImage
        guard let nsImage = NSImage(named: imageName) else {
            return ""
        }

        // Convert the NSImage to a CIImage
        self.ciImage = nsImage.ciImage()

        // Convert the NSImage to a CGImage
        self.cgImage = ciImage.cgImage

        // Create a CIContext
        let context = CIContext()

        // Define the pixel buffer attributes
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)
        let pixelBufferOptions: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]

        // Create the pixel buffer
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, pixelBufferOptions as CFDictionary, &pixelBuffer)

        // Render the CIImage into the pixel buffer
        context.render(ciImage, to: pixelBuffer!)
        
        guard let pixelBuffer = pixelBuffer else {
            return ""
        }

        
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let observation = request.results?.first as? VNFaceObservation else {
                return
            }
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            self.faceBound = VNImageRectForNormalizedRect(observation.boundingBox, width, height)
            
            self.performEmotionAnalysis()
            
            
            
        }
        guard let currentCIImage = self.ciImage else { return "" }
        
        do {
            let requestHandler = VNSequenceRequestHandler()
            try requestHandler.perform([request], on: currentCIImage)
        }
        catch {
           print(error)
        }
        return emotion
    }
    
    private func performEmotionAnalysis() {
        //print("performEmotionAnalysis")
        if let image = ciImage {
            let ciFaceImage = image.cropped(to: self.faceBound)
            
//            guard let cgFaceImage = ciFaceImage.cgImage else {
//                print("sorry")
//                return
//            }
            //print("performEmotionAnalysis")
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print(error)
            }
        }
    }
    
    private func handleEmotionsClassification(request: VNRequest, error: Error?) {
        //print("handleEmotionClassification")
        if let result = request.results as? [VNClassificationObservation], result.count > 0 {

            let topClassifications = Array(result.prefix(7))

            var information = [String:Double]()
            for observation in topClassifications {

                switch observation.identifier {
                case "happy":
                    information["happyScore"] = Double(observation.confidence)
                case "angry":
                    information["angryScore"] = Double(observation.confidence)
                case "disgust":
                    information["disgustScore"] = Double(observation.confidence)
                case "fear":
                    information["fearScore"] = Double(observation.confidence)
                case "sad":
                    information["sadScore"] = Double(observation.confidence)
                case "surprise":
                    information["surpriseScore"] = Double(observation.confidence)
                case "neutral":
                    information["neutralScore"] = Double(observation.confidence)
                default:
                    break
                }

            }
            
//            print("printing data...")
//            for info in information {
//                print("\(info.key) -> \(info.value)")
//            }
//            print("done")
            let descriptions = topClassifications.map { classification in
                return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                //return String(classification.identifier)
            }
            self.emotion = "Emotion:\n" + descriptions.joined(separator: "\n")
            //self.emotion = "Emotion: " + (descriptions.first ?? "not found!")
        }
    }
}
