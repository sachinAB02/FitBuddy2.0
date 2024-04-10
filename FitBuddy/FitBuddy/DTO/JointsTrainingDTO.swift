//
//  JointsTrainingDTO.swift
//  FitBuddy
//
//  Created by Sachin on 2024-03-27.
//

import Foundation
struct JointsTrainingDTO {
    let Time: TimeInterval
    var Joint_1_x: Float
    var Joint_1_y: Float
    var Joint_1_z: Float
    
    var Joint_2_x: Float
    var Joint_2_y: Float
    var Joint_2_z: Float
    
    var Joint_3_x: Float
    var Joint_3_y: Float
    var Joint_3_z: Float
    
    var correct : Int = 0
    
    init(joint_1: SIMD3<Float>, joint_2: SIMD3<Float>, joint_3: SIMD3<Float> , Time: TimeInterval){
        
        self.Time = Time
        
        self.Joint_1_x = joint_1.x
        self.Joint_1_y = joint_1.y
        self.Joint_1_z = joint_1.z
        
        self.Joint_2_x = joint_2.x
        self.Joint_2_y = joint_2.y
        self.Joint_2_z = joint_2.z
        
        self.Joint_3_x = joint_3.x
        self.Joint_3_y = joint_3.y
        self.Joint_3_z = joint_3.z
        
      }

}
