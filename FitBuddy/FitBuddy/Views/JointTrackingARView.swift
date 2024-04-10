//
//  ARViewContainer.swift
//  FitBuddy
//
//  Created by Sachin on 2024-01-13.
//

import SwiftUI
import ARKit
import RealityKit

private var bodySkeleton: BodySkeletonForJointTracking?
private var bodySkeletonAnchor = AnchorEntity()

struct JointTrackingARView : UIViewRepresentable {
    var selection = 0
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.setupForBodyTracking()
        arView.scene.addAnchor(bodySkeletonAnchor)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}
extension ARView: ARSessionDelegate {
    func setupForBodyTracking(){
        let config = ARBodyTrackingConfiguration()
        self.session.run(config)
        
        self.session.delegate = self
    }
    
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                if let skeleton = bodySkeleton{
                    skeleton.update(with: bodyAnchor)
                } else {
                    bodySkeleton = BodySkeletonForJointTracking(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(bodySkeleton!)
                }
            }
        }
    }
}




 
