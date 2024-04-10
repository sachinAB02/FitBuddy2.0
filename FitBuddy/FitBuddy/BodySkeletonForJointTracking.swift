//
//  BodySkeleton.swift
//  FitBuddy
//
//  Created by Sachin on 2024-02-09.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI
class BodySkeletonForJointTracking: Entity{
    var bones: [String: Entity] = [:]
    var joints: [String: Entity] = [:]
    var timer: Timer?
    var myModel : my_model?
    private var startTime: TimeInterval = 0
    var isRunning: Bool {
            return timer != nil
        }
    var currentSecond: Int = 0
    var elapsedTime: TimeInterval {
            if isRunning {
                return Date().timeIntervalSince1970 - startTime
            } else {
                return 0
            }
        }
    var LeftAngle : Float = 0.0
    var RightAngle : Float = 0.0
    
    var joint_1 : SIMD3<Float> = SIMD3<Float>.init()
    var joint_2 : SIMD3<Float> = SIMD3<Float>.init()
    var joint_3 : SIMD3<Float> = SIMD3<Float>.init()
    
    var arrayOfJointAngleData = [JointAngleDTO]()
    
    var arrayOfJointData = [JointsTrainingDTO]()
    var Score = "."

    //create constants for parameters of the Sine curve y = A.Sin(Bx + C) + D which will be used for pace tracking
    let param_A : Float = -33.602335886631465
    let param_B : Float = 2.742468493655414
    let param_C : Float = 2.9650919834508307
    let param_D : Float = 116.13037400024918
    
    
    required init(for bodyAnchor: ARBodyAnchor) {
        super.init()
        
        startTimer()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            var jointRadius: Float = 0.05
            var jointColor: UIColor = .blue
            let dataManager = FeedbackDataManager.shared
            switch jointName {
            case "neck_1_joint", "neck 2 joint", "nec/Users/sachin/Desktop/Screenshots/Screen Recording 2024-02-15 at 11.14.07.movk_3_joint", "neck_4_joint", "head_joint":
                
                jointRadius *= 0.5
                
            case "chin joint" , "jaw_joint", "left_eye_joint", "left_eyeLowerLid_joint", "left_eyeUpperLid_joint",
                "left_eyeball_joint", "nose_joint", "right_eye_joint","right_eyeLowerLid_joint",
                "right_eyeUpperLid_joint","right_eyeball_joint" :
                
                jointRadius *= 0.2
                jointColor = .yellow
                
            case _ where jointName.hasPrefix("left_hand") || jointName.hasPrefix("right_hand"):
                jointRadius *= 0.25
                jointColor = .yellow
            case _ where jointName.hasPrefix("left_toes") || jointName.hasPrefix("right_toes"):
                jointRadius *= 0.5
                jointColor = .yellow
            case _ where jointName.hasPrefix("spine_"):
                jointRadius *= 0.75
            case "left_hand_joint","right_hand_joint","right_forearm_joint","left_forearm_joint","right_arm_joint", "left_arm_joint":
                jointRadius *= 1
                if(dataManager.feedbackMeasurement == "Confidence"){
                    switch dataManager.score {
                    case 0...0.25:
                        jointColor = .red
                    case 0.26...0.5:
                        jointColor = .systemPink
                    case 0.51...0.75:
                        jointColor = .cyan
                    case 0.76...1:
                        jointColor = .green
                    default:
                        jointColor = .yellow
                    }
                }
                
                
            default:
                jointRadius *= 0.05
                jointColor = .yellow
                
            }
            
            
            
            let jointEntity = createJointEntity(radius: jointRadius , color: jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
        }
        
        for bone in Bones.allCases {
           guard let skeletonBone = createBone(bone: bone, bodyAnchor: bodyAnchor)
            else {
               continue
           }
            let boneEntity = createBoneEntity(for: skeletonBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func update(with bodyAnchor: ARBodyAnchor){
        var right_arm_joint : simd_float3?
        var right_forearm_joint : simd_float3?
        var right_hand_joint : simd_float3?
        
        var left_arm_joint : simd_float3?
        var left_forearm_joint : simd_float3?
        var left_hand_joint : simd_float3?
        
        GlobalVariable.AngleArray = arrayOfJointAngleData
        GlobalVariable.arrayOfJointData = arrayOfJointData
        GlobalVariable.Score = Score
        
        let originPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            if let jointEntity = joints[jointName],
               let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)){
                
                let jointEntityOffsetFromOrigin = simd_make_float3(jointEntityTransform.columns.3)
                jointEntity.position = jointEntityOffsetFromOrigin + originPosition
                jointEntity.orientation = Transform(matrix: jointEntityTransform).rotation
                self.addChild(jointEntity)
                switch jointName {
                    
                case "right_arm_joint":
                    right_arm_joint = jointEntity.position
                    
                case "right_forearm_joint":
                    right_forearm_joint = jointEntity.position
                case "right_hand_joint":
                    right_hand_joint = jointEntity.position
                    
                case "left_arm_joint":
                    left_arm_joint = jointEntity.position
                case "left_forearm_joint":
                    left_forearm_joint = jointEntity.position
                case "left_hand_joint":
                    left_hand_joint = jointEntity.position
                    
                default : break
                }
                
            }
            
        }
        joint_1 = right_arm_joint!
        joint_2 = right_forearm_joint!
        joint_3 = right_hand_joint!
        
        RightAngle = calculateJointAngle2(joint_1: right_arm_joint!, joint_2: right_forearm_joint!, joint_3: right_hand_joint!)
        
        LeftAngle = calculateJointAngle2(joint_1: left_arm_joint!, joint_2: left_forearm_joint!, joint_3: left_hand_joint!)
        
        
        for bone in Bones.allCases {
            
            let boneName = bone.name
            
            guard let entity = bones[boneName],
                  let skeletonBone = createBone(bone: bone, bodyAnchor: bodyAnchor)
            else{
                continue
            }
            
            entity.position = skeletonBone.centerPosition
            entity.look(at: skeletonBone.toJoint.jointPosition, from: skeletonBone.centerPosition, relativeTo: nil)
        }
        
    }
    
    private func createJointEntity(radius: Float, color: UIColor = .white) -> Entity {
        let jointMesh = MeshResource.generateSphere(radius: radius)
        let jointMaterial = SimpleMaterial(color: color,roughness: 0.7, isMetallic: false)
        let entity = ModelEntity(mesh: jointMesh , materials: [jointMaterial])
        
        return entity
    }
    
    private func createBone(bone: Bones , bodyAnchor : ARBodyAnchor) -> SkeletonBone? {
        guard let fromJointEntityModelTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointFromName)),
              let toJointEntityModelTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointToName))
        else {
            return nil
        }
        
        let originPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        let fromJointEntityOffsetFromOrigin = simd_make_float3(fromJointEntityModelTransform.columns.3)
        let fromJointEntityPosotion = originPosition + fromJointEntityOffsetFromOrigin
        
        let toJointEntityOffsetFromOrigin = simd_make_float3(toJointEntityModelTransform.columns.3)
        let toJointEntityPosotion = originPosition + toJointEntityOffsetFromOrigin
        
        let fromJoint = SkeletonJoint(jointName: bone.jointFromName, jointPosition: fromJointEntityPosotion)
        let toJoint = SkeletonJoint(jointName: bone.jointToName, jointPosition: toJointEntityPosotion)

        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)

    }
    
    private func createBoneEntity(for skeletonBone: SkeletonBone, diameter: Float = 0.04, color: UIColor = .white) -> Entity {
        let boneMesh = MeshResource.generateBox(size: [diameter,diameter,skeletonBone.length], cornerRadius: diameter/2)
        let boneMaterial = SimpleMaterial(color: color,roughness: 0.5, isMetallic: false)
        let entity = ModelEntity(mesh: boneMesh , materials: [boneMaterial])
        
        return entity
    }
    
    private func calculateJointAngle(joint_1 : simd_float3 ,joint_2 : simd_float3 ,joint_3 : simd_float3  ) -> Float  {
        let lengthFrom1to2 = calculateJointLength(joint_1: joint_1, joint_2: joint_2 )
        let lengthFrom2to3 = calculateJointLength(joint_1: joint_2, joint_2: joint_3 )
        let lengthFrom1to3 = calculateJointLength(joint_1: joint_1, joint_2: joint_3 )
        
        let angleAtJoint_2 = acos( ((lengthFrom1to2 * lengthFrom1to2)
                                   + (lengthFrom2to3 * lengthFrom2to3)
                                   -  (lengthFrom1to3 * lengthFrom1to3)) / 2*lengthFrom1to2*lengthFrom2to3)
        return angleAtJoint_2
    }
    
    private func calculateJointAngle2(joint_1 : simd_float3 ,joint_2 : simd_float3 ,joint_3 : simd_float3  ) -> Float  {
        let radians = atan2(joint_3.y - joint_2.y , joint_3.x - joint_2.x) -
                        atan2(joint_1.y - joint_2.y , joint_1.x - joint_2.x)
        var angle = radians * 180 / .pi
        if angle > 180 {
            angle = 360 - angle
        }
        return angle
    }
    
    private func calculateJointLength(joint_1 : simd_float3 ,joint_2 : simd_float3) -> Float {
        
        let length = ((joint_2.x - joint_1.x)*(joint_2.x - joint_1.x)
                      +
                      (joint_2.y - joint_1.y)*(joint_2.y - joint_1.y)
                      +
                      (joint_2.z - joint_1.z)*(joint_2.z - joint_1.z)).squareRoot()
        return length
    }
    
    func startTimer() {
            if !isRunning {
                startTime = Date().timeIntervalSince1970
                timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [self] timer in
                    // Do something every millisecond
                    if(GlobalVariable.isPaceTracking){
                        //do pace tracking with angle data
                        doPaceTracking()
                    }
                    if(!GlobalVariable.isPaceTracking){
                        //do joint tracking with the model
                        doJointTracking()
                    }
                    //uncomment the below lines inorder to perfrom data export
                    let AngleData = JointAngleDTO(Time: self.elapsedTime, RightAngle: self.RightAngle, LeftAngle: self.LeftAngle)
                    let JointTrainingData = JointsTrainingDTO(joint_1: self.joint_1, joint_2: self.joint_2, joint_3: self.joint_3, Time: self.elapsedTime)
                    self.arrayOfJointData.append(JointTrainingData)
                    self.arrayOfJointAngleData.append(AngleData)
                }
                
                // Ensure timer fires immediately
                timer?.fire()
            }
        }
        
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    struct GlobalVariable{
       static var AngleArray = [JointAngleDTO]()
       static var arrayOfJointData = [JointsTrainingDTO]()
       static var isPaceTracking = Bool()
       static var TypeOfReading = ""
       static var Score = ""
       
    }
    
    func doJointTracking(){
        if(Int(elapsedTime) % 60 == self.currentSecond){
            //output for right arm movement
            let output = runModel(joint_1: self.joint_1, joint_2: self.joint_2, joint_3: self.joint_3)
            let confidence = round(output![0].floatValue*1000)/1000

            let dataManager = FeedbackDataManager.shared
            dataManager.feedbackMeasurement = "Confidence"
            dataManager.score = confidence <= 1 ? confidence : 0
            switch confidence {
            case 0...0.25:
                dataManager.feedback = "Very Bad"
                dataManager.feedbackTextColour = Color.red
            case 0.26...0.5:
                dataManager.feedback = "Bad"
                dataManager.feedbackTextColour = Color.pink
            case 0.51...0.75:
                dataManager.feedback = "Good"
                dataManager.feedbackTextColour = Color.cyan
            case 0.76...1:
                dataManager.feedback = "Very Good"
                dataManager.feedbackTextColour = Color.green
            default:
                dataManager.feedback = "Invalid"
                dataManager.feedbackTextColour = Color.red
            }

            self.currentSecond = self.currentSecond + 1
            
        }
    }
    func doPaceTracking(){
        //keep the current second count going
        if(Int(elapsedTime) % 60 == self.currentSecond){
            self.currentSecond = self.currentSecond + 1
        }
        let dataManager = FeedbackDataManager.shared
        dataManager.feedbackMeasurement = "Angle"
        dataManager.score = round((RightAngle*1000)/1000)
        
        //calculate the prediced angle at the current time according to y = A.Sin(Bx + C) + D where x is the current elapsed time.
        let predictedAngle = round(((param_A * sin(param_B*Float(elapsedTime) + param_C)) + param_D)*1000/1000)
        let absoluteDifference = abs(RightAngle - predictedAngle)
        let percentageError = (absoluteDifference/RightAngle) * 100
        switch percentageError {
        case 0...25:
            dataManager.feedback = "Predicted angle : \(predictedAngle)\nVery Good : Continue keeping up with the predicted angle"
            dataManager.feedbackTextColour = Color.green
        case 26...50:
            dataManager.feedback = "Predicted angle : \(predictedAngle)\nGood : Continue keeping up with the predicted angle"
            dataManager.feedbackTextColour = Color.cyan
        case 51...75:
            dataManager.feedback = "Predicted angle : \(predictedAngle)\nBad : Try keeping up with the predicted angle"
            dataManager.feedbackTextColour = Color.pink
        case 76...100:
            dataManager.feedback = "Predicted angle : \(predictedAngle)\nVery Bad : Try keeping up with the predicted angle    "
            dataManager.feedbackTextColour = Color.green
        default:
            dataManager.feedback = "Invalid Movement"
            dataManager.feedbackTextColour = Color.red
        }
        
    }
    
    //for testing purposes
    func runModel(joint_1 : simd_float3 ,joint_2 : simd_float3 , joint_3 : simd_float3) -> MLMultiArray? {
        if let mlModel = try? my_model(configuration: .init()){
            myModel = mlModel
        } else {
            fatalError("Failed to load model")
        }
        
        do{
            let inputArray = try MLMultiArray(shape: [1,3,3], dataType: .float32)
            
            inputArray[0] = joint_1.x as NSNumber
            inputArray[1] = joint_1.y as NSNumber
            inputArray[2] = joint_1.z as NSNumber
            inputArray[3] = joint_2.x as NSNumber
            inputArray[4] = joint_2.y as NSNumber
            inputArray[5] = joint_2.z as NSNumber
            inputArray[6] = joint_3.x as NSNumber
            inputArray[7] = joint_3.y as NSNumber
            inputArray[8] = joint_3.z as NSNumber
            
            let input = my_modelInput(flatten_4_input: inputArray)
            let output = try myModel?.prediction(input: input)
            
            return output?.Identity

            
        } catch {
            print("Prediction Error")
        }
        return nil
    }
    func changeJointEntityColor(entity: Entity, newColor: UIColor) -> Entity {
        // Ensure the entity is a ModelEntity
        guard let modelEntity = entity as? ModelEntity else {
            fatalError("Expected entity to be a ModelEntity")
        }
        
        // Ensure the entity has materials
        guard let materials = modelEntity.model?.materials else {
            fatalError("Expected entity to have materials")
        }
        
        // Ensure there is only one material (assuming single material for simplicity)
        guard materials.count == 1 else {
            fatalError("Expected only one material")
        }
        
        // Retrieve the existing material
        guard let existingMaterial = materials.first as? SimpleMaterial else {
            fatalError("Expected material to be SimpleMaterial")
        }
        
        // Create a new material with the updated color
        let newMaterial = SimpleMaterial(color: newColor, roughness: existingMaterial.roughness, isMetallic: false)
        
        let jointMesh = MeshResource.generateSphere(radius: 0.5)
        
        // Create a new model entity with the updated material
        let newModelEntity = ModelEntity(mesh: jointMesh, materials: [newMaterial])
        
        return newModelEntity
    }
    

    
    
    
    
    
}

