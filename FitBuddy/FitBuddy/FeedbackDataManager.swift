//
//  DataModel.swift
//  FitBuddy
//
//  Created by Sachin on 2024-04-02.
//

import Foundation
import Combine
import SwiftUI
class FeedbackDataManager: ObservableObject{
    static var shared = FeedbackDataManager()
    @Published var score: Float = round((0*100)/100)
    @Published var feedbackMeasurement: String = "Confidence"
    @Published var feedback: String = ""
    @Published var feedbackTextColour: Color = Color.black
    private init() {}
}
