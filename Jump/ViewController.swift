//
//  ViewController.swift
//  Jump
//
//  Created by nirvana on 2022/7/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var higestLabel: UILabel!
    @IBOutlet var currentLabel: UILabel!
    
    //记录所有方块
    private var boxNodes: [SCNNode] = []
    //记录分数
    private var scoreList: [Int] = []
    private var highestScore = 0
    //定义锚点
    private var currentAnchor: ARAnchor?
    //定义小人
    private lazy var bottleNode: BottleNode = {
        return BottleNode()
    }()
    //记录按压开始/结束时间
    private var touchTimePair: (begin: TimeInterval, end: TimeInterval) = (0, 0)
    //计算运动距离
    private var distance: CGFloat {
        return ((touchTimePair.end - touchTimePair.begin) / 4.0)
    }
    //记录安全范围
    private var boxnode1 : SCNNode!
    private var boxnode2 : SCNNode!
    //记录touch有效性
    private var touchCanWork: Bool = true
    //记录目前方向
    private var nextDirection: Direction = .left
    //用于判断小人状态来执行动画
    private var isTouched: Bool = false
    private let kMoveDuration: TimeInterval = 0.25
    private let kBoxWidth: CGFloat = 0.2
    private let kJumpHeight: CGFloat = 0.2
    private var score: Int = 0 {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                if score > highestScore {
                    self.higestLabel.text = "Highest:  \(score)"
                    highestScore = score
                }
                self.currentLabel.text = "Now:  \(self.score)"
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        //水平面检测
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        sceneView.session.run(configuration)

        restartGame()
    }
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "info", sender: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    //新游戏
    func restartGame() {
        touchTimePair = (0, 0)
        score = 0
        boxNodes.forEach {
            $0.removeFromParentNode()
        }
        bottleNode.removeFromParentNode()
        boxNodes.removeAll()
        touchCanWork = true
    }
    //生成方块
    func generateBox(at position: SCNVector3) {
        let box = SCNBox(width: kBoxWidth, height: kBoxWidth / 2.0, length: kBoxWidth, chamferRadius: 0.0)
        let node = SCNNode(geometry: box)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.randomColor
        box.materials = [material]
        //初始化位置
        if boxNodes.isEmpty {
            node.position = position
        } else {
            //随机方向
            nextDirection = Direction(rawValue: Int.random(in: 0...1))!
            //随机距离
            let deltaDistance = Double.random(in: 0.25...0.5)
            //放置方块
            switch nextDirection {
            case .left:
                node.position = SCNVector3(position.x + Float(deltaDistance), position.y, position.z)
            case .right:
                node.position = SCNVector3(position.x, position.y, position.z + Float(deltaDistance))
            }
        }
        //添加节点/记录方块
        sceneView.scene.rootNode.addChildNode(node)
        boxNodes.append(node)
        boxnode1 = boxnode2
        boxnode2 = boxNodes.last!
        
}
    //开始游戏
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentAnchor != nil && touchCanWork else {
            return
        }
        if boxNodes.isEmpty  {
            //放置小人
            func addConeNode() {
                bottleNode.position = SCNVector3(boxNodes.last!.position.x,
                                                 boxNodes.last!.position.y + Float(kBoxWidth) * 0.75,
                                                 boxNodes.last!.position.z)
                sceneView.scene.rootNode.addChildNode(bottleNode)
            }
            
            func anyPositionFrom(location: CGPoint) -> (SCNVector3)? {
                //检验获取特征点
                guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any) else {
                    return nil
                }
                let results = sceneView.session.raycast(query)
                return SCNVector3.positionFromTransform(results[0].worldTransform)
            }
            
            let location = touches.first?.location(in: sceneView)
            if let position = anyPositionFrom(location: location!) {
                //添加box并记录
                generateBox(at: position)
                boxnode1 = boxNodes.last!
                addConeNode()
                generateBox(at: boxNodes.last!.position)
                boxnode2 = boxNodes.last!
            }
        } else {
                //开始压缩动画
                isTouched.toggle()
                //记录开始时间
                touchTimePair.begin = (event?.timestamp)!
            touchCanWork.toggle()
        }
    }
    //结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        guard currentAnchor != nil && !boxNodes.isEmpty else {
            return
        }
        if isTouched {
            //结束压缩动画
            isTouched.toggle()
            //记录结束时间
            touchTimePair.end = (event?.timestamp)!
            //产生动画
            var actions = [SCNAction()]
            if nextDirection == .left {
                //移动+旋转(group动作合并；sequence动作连续进行)
                let moveAction1 = SCNAction.moveBy(x: distance, y: kJumpHeight, z: 0, duration: kMoveDuration)
                let moveAction2 = SCNAction.moveBy(x: distance, y: -kJumpHeight, z: 0, duration: kMoveDuration)
                actions = [SCNAction.rotateBy(x: 0, y: 0, z: -.pi * 2, duration: kMoveDuration * 2),
                           SCNAction.sequence([moveAction1, moveAction2])]
            } else {
                let moveAction1 = SCNAction.moveBy(x: 0, y: kJumpHeight, z: distance, duration: kMoveDuration)
                let moveAction2 = SCNAction.moveBy(x: 0, y: -kJumpHeight, z: distance, duration: kMoveDuration)
                actions = [SCNAction.rotateBy(x: .pi * 2, y: 0, z: 0, duration: kMoveDuration * 2),
                           SCNAction.sequence([moveAction1, moveAction2])]
            }
            //复原状态
            bottleNode.recover()
            bottleNode.runAction(SCNAction.group(actions), completionHandler: { [weak self] in
                //如果瓶子超出范围，则失败
                if (self?.bottleNode.isNotContainedXZ(in: self!.boxnode1))! && (self?.bottleNode.isNotContainedXZ(in: self!.boxnode2))!{
                    //记录分数/提升失败/重新开始
                    self?.scoreList.append(self!.score)
                    self?.restartGame()
                } else {
                    if (self?.bottleNode.isNotContainedXZ(in: self!.boxnode1))! {
                        //分数加1,继续进行
                        self?.score += 1
                        self?.generateBox(at: (self?.boxNodes.last!.position)!)
                    }
                    self?.touchCanWork.toggle()
                }
            })
        }
    }
    //发现锚点后运行此函数
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if currentAnchor == nil {
            self.currentAnchor = anchor
        }
            //光源
            let light = SCNLight()
            light.type = .directional
            light.color = UIColor(white: 1.0, alpha: 1.0)
            light.shadowColor = UIColor(white: 0.0, alpha: 0.8).cgColor
            let lightNode = SCNNode()
            lightNode.eulerAngles = SCNVector3Make(-.pi / 3, .pi / 4, 0)
            lightNode.light = light
            self.sceneView.scene.rootNode.addChildNode(lightNode)
    }
    //随时间检测状态
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            if self.isTouched {
                self.bottleNode.scaleHeight()
            }
    }
  
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func history(_ sender: Any) {
        
    }
}
