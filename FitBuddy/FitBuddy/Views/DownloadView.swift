//
//  DownloadView.swift
//  FitBuddy
//
//  Created by Sachin on 2024-03-19.
//

import SwiftUI
import Foundation
import CoreML

var myModel : my_model?

struct DownloadView: View {
    var body: some View {
        VStack{
            Image(uiImage: #imageLiteral(resourceName: "Logo.png"))
                .resizable()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10), style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                .padding()
            Spacer()
            Text("Click below to download the joint data file")
                .multilineTextAlignment(.center)
            
            Button("Download") {
                let output = OutputStream.toMemory()
                
                let fileName = "Wrong.csv"
                
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                
                let documentURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(fileName)
                
                let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
                csvWriter?.writeField("Joint_1_x")
                csvWriter?.writeField("Joint_1_y")
                csvWriter?.writeField("Joint_1_z")
                
                csvWriter?.writeField("Joint_2_x")
                csvWriter?.writeField("Joint_2_y")
                csvWriter?.writeField("Joint_2_z")
                
                csvWriter?.writeField("Joint_3_x")
                csvWriter?.writeField("Joint_3_y")
                csvWriter?.writeField("Joint_3_z")
                
                csvWriter?.writeField("Correct")
                csvWriter?.writeField("Time")
                csvWriter?.finishLine()
                
                print(BodySkeletonForJointTracking.GlobalVariable.arrayOfJointData.count)
                
                for(elements) in BodySkeletonForJointTracking.GlobalVariable.arrayOfJointData.enumerated(){
                    csvWriter?.writeField(elements.element.Joint_1_x)
                    csvWriter?.writeField(elements.element.Joint_1_y)
                    csvWriter?.writeField(elements.element.Joint_1_z)
                    
                    csvWriter?.writeField(elements.element.Joint_2_x)
                    csvWriter?.writeField(elements.element.Joint_2_y)
                    csvWriter?.writeField(elements.element.Joint_2_z)
                    
                    csvWriter?.writeField(elements.element.Joint_3_x)
                    csvWriter?.writeField(elements.element.Joint_3_y)
                    csvWriter?.writeField(elements.element.Joint_3_z)
                    
                    csvWriter?.writeField(elements.element.correct)
                    csvWriter?.writeField(elements.element.Time)
                    csvWriter?.finishLine()
                }
                csvWriter?.closeStream()
                
                let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
                
                do{
                    try buffer.write(to: documentURL)
                }
                catch{
                    
                }
                
                
                
            }
            .buttonStyle(.borderedProminent)
            .padding()
            Text("Click below to test the model and get a console output")
                .padding()
                .multilineTextAlignment(.center)
            Button("Test Model") {
                if let mlModel = try? my_model(configuration: .init()){
                    myModel = mlModel
                } else {
                    fatalError("Failed to load model")
                }
                
                do{
                    let inputArray = try MLMultiArray(shape: [1,3,3], dataType: .float32)
                    
                    inputArray[0] = 0.5
                    inputArray[1] = 0.3
                    inputArray[2] = 0.5
                    inputArray[3] = 0.7
                    inputArray[4] = 0.4
                    inputArray[5] = 0.9
                    inputArray[6] = 0.1
                    inputArray[7] = 0.5
                    inputArray[8] = 0.9
                    
                    let input = my_modelInput(flatten_4_input: inputArray)
                    let output = try myModel?.prediction(input: input)
                    
                    print(output?.Identity)

                    
                } catch {
                    print("Prediction Error")
                }
                
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

#Preview {
    DownloadView()
}
