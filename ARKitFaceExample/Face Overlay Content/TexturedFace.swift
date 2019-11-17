/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Displays the 3D face mesh geometry provided by ARKit, with a static texture.
*/

import ARKit
import SceneKit

class TexturedFace: NSObject, VirtualContentController {

    var contentNode: SCNNode?
    
    /// - Tag: CreateARSCNFaceGeometry
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        
        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!

//        material.shaderModifiers = [
//            SCNShaderModifierEntryPoint.fragment : """
//                texture2d<float, access::sample> diffuseTexture;
//                constexpr sampler mySampler(filter::linear, address::repeat);
//                float value = diffuseTexture.sample(mySampler, _surface.ambientTexcoord).r;
//                if (value < 0.5) {
//                    _output.color.rgb = float3(0.4, 0.8, 1);
//                }
//                else {
//                    _output.color.rgb = float3(0, 0.5, 1);
//                }
//            """
//        ]
        
        //material.ambientOcclusion.contents = #imageLiteral(resourceName: "AO")
        material.roughness.contents = #imageLiteral(resourceName: "roughness_1")
        let diffuseImg = #imageLiteral(resourceName: "diffuse_1")
        material.diffuse.contents = diffuseImg
        material.ambient.contents = diffuseImg
//        if button1Clicked
//        if lastButtonClicked == 1 {
//        material.diffuse.contents = diffuseImg
//        }
//        else {
//            material.diffuse.contents = #imageLiteral(resourceName: "roughness_1")
//            
//        }
//        material.roughness.contents = #imageLiteral(resourceName: "roughness_1")
        material.lightingModel = .physicallyBased
        
        contentNode = SCNNode(geometry: faceGeometry)
        #endif
        return contentNode
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        let material = faceGeometry.firstMaterial!
//        if button1Clicked
        if lastButtonClicked == 1 {
        material.diffuse.contents = #imageLiteral(resourceName: "diffuse_1")
        }
        else if lastButtonClicked == 2{
            material.diffuse.contents = #imageLiteral(resourceName: "roughness_1")
            
        }
        faceGeometry.update(from: faceAnchor.geometry)
    }

}
