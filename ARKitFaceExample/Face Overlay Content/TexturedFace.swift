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


        material.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment : """
                //texture2d<float, access::sample> diffuseTexture;
                //texture2d<float, access::sample> specularTexture;
                //constexpr sampler mySampler(filter::linear, address::repeat);
                //float4 specularColor = specularTexture.sample(mySampler, _surface.ambientTexcoord);
                float4 specularColor = _surface.specular;
                vec3 Normal = _surface.normal;
                vec3 Light = normalize(vec3(0.4, 0.5, 0.6));
                vec3 View = _surface.view;
                vec3 Half = normalize(Light + View);
                vec2 s;
                s.x = dot(Normal, LightVec);
                s.y = dot(Normal, Half);
                s = s * 0.5 + 0.5;
                s.x = min(0.996,s.x);
                float wrap = 0.2;
                float scatterWidth = 0.3;
                float4 scatterColor = float4(0.15, 0.0, 0.0, 1.0); ///// maybe change this??
                float shininess = 40.0; // ???
                float NdotL = s.x * 2.0 - 1.0;  // remap from [0, 1] to [-1, 1]
                float NdotH = s.y * 2.0 - 1.0;
                float NdotL_wrap = (NdotL + wrap) / (1 + wrap); // wrap lighting
                float diffuse = max(NdotL_wrap, 0.0);
                // add color tint at transition from light to dark
                float scatter = smoothstep(0.0, scatterWidth, NdotL_wrap) *
                                    smoothstep(scatterWidth * 2.0, scatterWidth,
                                            NdotL_wrap);
                float specularIntensity = pow(NdotH, shininess);
                if (NdotL_wrap <= 0) specular = 0;
                vec3 sss = diffuse + scatter * scatterColor;

                _output.color.rgb = _output.color.rgb * sss + specularIntensity * specularColor;

            """
        ]
        
        //material.setValue(SCNMaterialProperty(contents: diffuseImg), forKey: "diffuseTexture")
        //material.ambientOcclusion.contents = #imageLiteral(resourceName: "AO")
        material.roughness.contents = #imageLiteral(resourceName: "roughness_1")
        material.diffuse.contents = #imageLiteral(resourceName: "diffuse_1")
        material.specular.contents = #imageLiteral(resourceName: "specular_1")
        material.normal.contents = #imageLiteral(resourceName: "normal_1")
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
