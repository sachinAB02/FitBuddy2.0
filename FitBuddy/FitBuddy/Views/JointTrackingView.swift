//
//  HomePage.swift
//  FitBuddy
//
//  Created by Sachin on 2024-03-31.
//

import SwiftUI

struct JointTrackingView: View {
    @State private var isPaceTracking = false
    @StateObject var feedbackDataManager = FeedbackDataManager.shared
    var body: some View {
        ZStack(alignment:.bottom){
            VStack {
                JointTrackingARView()
                VStack{
                    HStack{
                        Toggle("Pace Tracking",isOn: $isPaceTracking).onChange(of: isPaceTracking) { newValue in
                            BodySkeletonForJointTracking.GlobalVariable.isPaceTracking = isPaceTracking
                            
                        }
                        
                        Text("\(feedbackDataManager.feedbackMeasurement) : ").padding()
                        Text("\(feedbackDataManager.score)").padding()
                    }.padding()
                        .frame(height: 80)
                    Text(feedbackDataManager.feedback)
                        .foregroundColor(feedbackDataManager.feedbackTextColour)
                        .padding()
                }
                
                
            }

        }
    }
    
}

#Preview {

    JointTrackingView()
}
