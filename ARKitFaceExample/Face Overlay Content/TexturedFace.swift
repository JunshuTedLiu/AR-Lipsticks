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
                uniform float ambientLevel = 0.3;
                uniform float shininess = 40.0;
                uniform float3 mainColor = float3(245.0 / 255.0, 0.0, 0.0);
                 //texture2d<float, access::sample> diffuseTexture;
                 //texture2d<float, access::sample> specularTexture;
                 //constexpr sampler mySampler(filter::linear, address::repeat);
                 //float4 specularColor = specularTexture.sample(mySampler, _surface.ambientTexcoord);
                float4 specularColor = _surface.specular;
                float3 Normal = _surface.normal;
                float3 Light = normalize(float3(0.2, 0.3, 1.0));
                float3 View = _surface.view;
                float3 Half = normalize(Light + View);
                float2 s;
                s.x = dot(Normal, Light);
                s.y = dot(Normal, Half);
                s = s * 0.5 + 0.5;
                s.x = min(0.996,s.x);
                float wrap = 0.2;
                float scatterWidth = 0.3;
                float4 scatterColor = float4(0.15, 0.0, 0.0, 1.0); ///// maybe change this??
                float NdotL = s.x * 2.0 - 1.0;  // remap from [0, 1] to [-1, 1]
                float NdotH = s.y * 2.0 - 1.0;
                float NdotL_wrap = (NdotL + wrap) / (1 + wrap); // wrap lighting
                float diffuse = max(NdotL_wrap, 0.0);
                // add color tint at transition from light to dark
                float scatter = smoothstep(0.0, scatterWidth, NdotL_wrap) *
                                    smoothstep(scatterWidth * 2.0, scatterWidth,
                                            NdotL_wrap);
                float specularIntensity = pow(NdotH, shininess);
                if (NdotL_wrap <= 0) specularIntensity = 0;
                float3 sss = max(diffuse + scatter * scatterColor.rgb, ambientLevel);

                _output.color.rgb = _output.color.rgb * sss * mainColor + specularIntensity * specularColor.rgb;

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
        material.setValue(NSValue(0.2), forKey: "ambientLevel")
        material.setValue(NSValue(10.0), forKey: "shininess")
        material.setValue(NSValue(SCNVector3: SCNVector3Make(155.0 / 255.0, 47.0 / 255.0, 54.0 / 255.0), forKey: "mainColor")
        }
        else if lastButtonClicked == 2{
        material.setValue(NSValue(0.35), forKey: "ambientLevel")
        material.setValue(NSValue(40.0), forKey: "shininess")
        material.setValue(NSValue(SCNVector3: SCNVector3Make(221.0 / 255.0, 78.0 / 255.0, 115.0 / 255.0), forKey: "mainColor")
            
        }
        faceGeometry.update(from: faceAnchor.geometry)
    }

}
