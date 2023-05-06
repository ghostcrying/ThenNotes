# ARKit



### 1. 资料

- [官方文档](https://developer.apple.com/documentation/arkit)

- [ARKit3.5 框架学习](https://juejin.cn/post/6844904130545188872)

- [Awesome-ARKit](https://github.com/olucurious/Awesome-ARKit)

- [直击苹果ARKit技术](https://juejin.cn/post/6844903815670398983)

- [ARKit初探](https://juejin.cn/post/6844903521364475918)

- [ARKit核心学习](https://juejin.cn/post/6844904130545188872#heading-75)

- [3D Models 下载](https://www.turbosquid.com/AssetManager/Index.cfm?stgAction=getFiles&subAction=Download&intID=1725126&intType=3)
- JoyARKitShow



### 2. 模型加载预览

##### 1. Apple通用模型预览(QLPreviewController)

- 格式
  - usdz

- reality

- 本地预览
  - [参考](https://developer.apple.com/documentation/arkit/previewing_a_model_with_ar_quick_look)

- ARQuickLookPreviewItem

- 在线预览
  - [参考](https://developer.apple.com/documentation/arkit/adding_an_apple_pay_button_or_a_custom_action_in_ar_quick_look)

- 可以进行自定义UI

##### 2. 其他模型预览

- gltf格式
  - 采用三方库调用(不友好)

- [GLTFSceneKit](https://github.com/magicien/GLTFSceneKit/)

- obj/dae/scn
  - SCNReferenceNode
    - 通过创建Node, 然后rootNode.addChild()添加到plane上

- SCNScene

  ```
  guard let urlPath = Bundle.main.url(forResource: "toy_drummer", withExtension: "usdz") else { return }
  
  let asset = MDLAsset(url: urlPath)
  asset.loadTextures()
  
  let scene = SCNScene(mdlAsset: asset)
  sceneView.scene = scene
  ```

- 引导视图UI

  - 在sceneview添加ARCoachingOverlayView(ARCoachingOverlayViewDelegate)

    ```
    let coachingOverlay = ARCoachingOverlayView()
    
    // Set up coaching view
    coachingOverlay.session = sceneView.session
    coachingOverlay.delegate = self
    coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
    sceneView.addSubview(coachingOverlay)
    NSLayoutConstraint.activate([
        coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
        coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])
    
    coachingOverlay.activatesAutomatically = true
    coachingOverlay.goal = .horizontalPlane
    ```

- 模型手势(参照QLPreview展示UI的手势)
  - 在SceneView添加自定义手势(关闭cameraControll)

- 参考代码
  - VirtualObjectInteraction

- 模型放置辅助视图
  - 可以添加平面Anchor辅助

- 添加Node组合辅助

- [参考代码](https://developer.apple.com/documentation/arkit/environmental_analysis/placing_objects_and_handling_3d_interaction/)
  - FocusSquare



### 3. 面部识别

##### 1. AR面部追踪: [ARFaceTrackingConfiguration](https://developer.apple.com/documentation/arkit/arfacetrackingconfiguration/)

##### 2. 特征检测

- 特征点: [ARFaceAnchor.BlendShapeLocation](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation/) (50+)

  - mouthSmileLeft 嘴巴左侧微笑

  - mouthSmileRight 嘴巴右侧微笑

  - cheekPuff 脸部

  - tongueOut 舌头伸出

  - ...

- 根据特征点的参数来表示检测到的面部表情

##### 3. 人脸识别

- 首先需要CreateML进行人脸模型训练(导出xxx.mlmodel文件)

- 开启面部追踪, 设定面部节点样式
  - 通常使用SCNFillMode.fill显示样式

- 在节点更新代理中进行识别

- [参考](https://www.appcoda.com/arkit-face-tracking/)



### 4. 身体识别

- AR身体追踪
  - [ARBodyTrackingConfiguration](https://developer.apple.com/documentation/arkit/arbodytrackingconfiguration/)



### 5. 模型识别

##### 1. [官方Demo](https://developer.apple.com/documentation/arkit/content_anchors/scanning_and_detecting_3d_objects/)

- 通过Scenekit+ARKit进行模型训练(arobject)

- 设定相机追踪对象: detectionObjects

- 在节点添加代理中判定识别到的对象是否是需求
  - ARObjectAnchor.referenceObject

##### 2. 积木识别逻辑方案

- 通过CreateML进行模型训练

  - 训练的模型包含所有的积木(包含训练,验证,测试三种)

  - 同面部识别逻辑, 进行识别

  - 此方案可以将多个模型组合到一起进行识别

- 类似官方Demo, 进行单一模型Object训练

  - 通过积木节点在不同角度然后匹配识别

  - 此方案识别率较高

  - 目前还无法进行大量模型组合训练



### 6. 积木搭建

##### 1. 节点坐标逻辑

- 添加同级节点

  ```
  计算节点的尺寸: boundBox
  - width: a.boundBox.max.x - a.boundBox.min.x
  - height: a.boundBox.max.y - a.boundBox.min.y
  - depth: a.boundBox.max.z - a.boundBox.min.z
  
  节点a已知, 节点b添加可以相对A的位置添加
  - x轴: 以a.position.x + width可以求得相邻位置b的position
  - y/z同理
  ```

- 添加子节点

  ```
  子节点的位置自定义即可
  - 是相对于父节点的坐标系, 即(0, 0 ,0)
  - 但是子节点会根据父节点的位置变化而变化
  ```

##### 2. 搭建

- 检测平面

- 添加积木节点

  - 每一个模块的积木以第一块积木为根节点, 作为相对坐标添加childnode

  - 记录Node行为数组, 作为前进后退处理依据.