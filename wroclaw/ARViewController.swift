//
//  ARViewController.swift
//  wroclaw
//
//  Created by Nazar on 20/05/2019.
//  Copyright © 2019 N&M 2016. All rights reserved.
//

import UIKit
import ARKit


class ARViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var ObjPosition = [0.0, 0.0]
    var UserPosition = [0.0, 0.0]
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func measure(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> [Double]{  // generally used geo measurement function
        let R = 6378.137
        let dLat = lat2 * Double.pi / 180 - lat1 * Double.pi / 180
        let dLon = lon2 * Double.pi / 180 - lon1 * Double.pi / 180
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1 * Double.pi / 180) * cos(lat2 * Double.pi / 180) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = R * c
        let x = (UserPosition[0] - ObjPosition[0])
        let y = (UserPosition[1] - ObjPosition[1])

        let angle = atan2f(Float(y), Float(x))
        let resultx = (d * 1000) * Double(cos(angle))
        let resulty = (d * 1000) * Double(sin(angle))
        return [resultx, resulty]
    }
    
    func addArrow() {
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:-0.25, y:0))
        bezierPath.addLine(to: CGPoint(x:0, y:-0.25))
        bezierPath.addLine(to: CGPoint(x:0.25, y:0))
        bezierPath.addLine(to: CGPoint(x:0, y:0.25))
        bezierPath.close()
        let shape = SCNShape(path: bezierPath, extrusionDepth: 0.75)
        
        let triangleNode = SCNNode()
//        boxNode.geometry = box
//        boxNode.position = SCNVector3(0, 0, -0.2)
        triangleNode.geometry = shape
        let x = (UserPosition[0] - ObjPosition[0])
        let y = (UserPosition[1] - ObjPosition[1])
        
        let angle = atan2f(Float(y), Float(x));
        let resultx = (1) * cos(angle) - (0) * sin(angle);
        let resulty = (1) * sin(angle) + (0) * cos(angle);
        triangleNode.position = SCNVector3(resultx, resulty, -2)
//        triangleNode.eulerAngles = angle
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(triangleNode)
        sceneView.scene = scene
    }
    
    func addLine(){
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:0, y:0))
        let user_c = measure(lat1: UserPosition[0], lon1: UserPosition[1], lat2: ObjPosition[0], lon2: ObjPosition[1])
        bezierPath.addLine(to: CGPoint(x:user_c[0], y:user_c[1]))
        let shape = SCNShape(path: bezierPath, extrusionDepth: 2)
        let lineNode = SCNNode()
        lineNode.geometry = shape
        lineNode.position = SCNVector3(0, 0,-4)
        let scene = SCNScene()
        scene.rootNode.addChildNode(lineNode)
        sceneView.scene = scene
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addArrow()
        addLine()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
