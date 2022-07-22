//
//  extension.swift
//  Jump
//
//  Created by nirvana on 2022/7/22.
//

import Foundation
import UIKit
import ARKit

enum Direction: Int {
    case left = 0
    case right = 1
}

extension  UIColor  {
     class  var  randomColor:  UIColor  {
         get  {
             let  red =  CGFloat (arc4random()%256)/255.0
             let  green =  CGFloat (arc4random()%256)/255.0
             let  blue =  CGFloat (arc4random()%256)/255.0
             return  UIColor (red: red, green: green, blue: blue, alpha: 1.0)
         }
     }
}
//扩展一个坐标转换方法
extension SCNVector3 {
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}
//扩展一个判断失败方法:当瓶子距离方块中心在x/z方向上绝对值大于一半宽度，判断为超出
extension SCNNode {
    func isNotContainedXZ(in boxNode: SCNNode) -> Bool {
        let box = boxNode.geometry as! SCNBox
        let width = Float(box.width)
        if abs(position.x - boxNode.position.x) > width / 2.0 {
            return true
        }
        if abs(position.z - boxNode.position.z) > width / 2.0 {
            return true
        }
        return false
    }
}

extension UIViewController {
    func alert(message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
