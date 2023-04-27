//
//  ContentView.swift
//  Study-CoreML-SwiftUI
//
//  Created by ShafiulAlam-00058 on 3/30/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @State var photos: [String] = ["happy", "neutral", "fear"]
    @State private var result: String = "No result found"
    @State private var index: Int = 0
    
    private func ImageClassification() {
        
        VisionManager.shared.setupVision()
        
        result = VisionManager.shared.classifyImage(imageName: photos[index])
    }
    
    var body: some View {
        VStack {
            Image(photos[index])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 200, alignment: .center)
                .border(.gray)
            Spacer()
            HStack {
                // left button
                Button {
                    if index > 0 {
                        index -= 1
                    }
                } label: {
                    Image(systemName: "arrow.left")
                }
                
                //right button
                Button {
                    if index == photos.count-1 {
                        index = 0
                    }
                    else {
                        index += 1
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
            
            HStack {
                Text(result)
                    .font(.title2)
                    .padding()
                Button {
                    self.ImageClassification()
                } label: {
                    Text("Classify")
                }
            }
            .shadow(color: .gray, radius: 5, x: 10, y: 10)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
