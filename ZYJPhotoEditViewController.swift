//
//  ZYJPhotoEditViewController.swift
//  ZYJ
//
//  Created by 陈瑞晓 on 2023/10/27.
//

import CoreImage
import JXSegmentedView
import SVProgressHUD
import TZImagePickerController
import UIKit

// MARK: - CvMatData

struct CvMatData {
    var data          : UnsafeMutableRawPointer?
    var width         : Int32
    var height        : Int32
    var bytesPerPixel : Int32
}

// MARK: - ZYJPhotoEditViewController

class ZYJPhotoEditViewController: ZYJBaseViewController {
    
    // MARK: - Properties
    
    var origialImage = UIImage()

    var selectedAssets = [Any]()

    var selectedPhotos = [UIImage]()

    var type: String = ""
    
    var pushSelectedPhotos = [UIImage]()

    var imgurl: String = ""

    // MARK: - Views
    
    let backView = UIView()
    
    lazy var backImage: UIImageView = {
        let icon = UIImageView()
        let url: URL? = URL(string: imgurl)
        icon.kf.setImage(with: url)
        icon.kf.setImage(with: url, completionHandler: { result in
            switch result {
            case let .success(retriImage):
                self.origialImage = retriImage.image
            default:
                break
            }
        })
        icon.backgroundColor = .white
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["偏低", "轻微", "中等", "正常", "高等"])
        segmentedControl.selectedSegmentIndex = 3
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.black,
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.white,
        ], for: .selected)
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "#3B3838")
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var homeMineButton: UIBarButtonItem = .init(title: "打印", style: .plain, target: self, action: #selector(showConfirmationAlert))

    private lazy var lianjieButton: UIBarButtonItem = .init(title: "连接", style: .plain, target: self, action: #selector(lianjiePhoto))

    private lazy var baocunButton: UIBarButtonItem = .init(title: "保存", style: .plain, target: self, action: #selector(savetapped5))

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configBasic()
        self.configBackView()
        
        self.configDensity()
        self.configEditViews()
    }

    // MARK: - Config Views
    
    func configBasic() {
        self.navigationItem.rightBarButtonItems = [self.homeMineButton, self.lianjieButton]
        self.title = "图片编辑"
        // self.view.backgroundColor = UIColor(hex: "#3B3838")
        self.view.backgroundColor = .white

        if self.type == "1" {
            self.backImage.image = self.pushSelectedPhotos[0]
        }
    }
    
    func configBackView() {
        self.view.addSubview(self.backImage)
        self.backImage.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-70)
        }

        self.view.addSubview(self.backView)
        self.backView.backgroundColor = UIColor(hex: "#3B3838")
        self.backView.snp.makeConstraints { make in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(70)
        }
    }
    
    func configDensity() {
        self.backView.addSubview(self.segmentControl)
        self.segmentControl.snp.makeConstraints {
            $0.left.equalTo(12)
            $0.right.equalTo(-12)
            $0.height.equalTo(36)
            $0.bottom.equalTo(-82)
        }
    }
    
    func configEditViews() {
        /*
         * 三个button
         * AppWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
         * AppHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
         */
        for index in 0 ..< 5 {
            // 按钮
            let shareBtn = UIButton(frame: CGRectMake((screenWidth / 5) * CGFloat(index) + screenWidth / 5 / 5, 20, screenWidth / 4 / 4, screenWidth / 4 / 4))
            // 图片名需要拼接下
            let imageStr = "edit_"
            let imageName = imageStr + String(index)
            shareBtn.setImage(UIImage(named: imageName), for: .normal)
            self.backView.addSubview(shareBtn)
            // 图片下的文字
            let shareLabel = UILabel(frame: CGRect(x: (screenWidth / 5) * CGFloat(index) + screenWidth / 6 / 6, y: 20 + shareBtn.frame.size.height, width: shareBtn.frame.size.width + 10, height: 25))
            shareLabel.textAlignment = .center
            shareLabel.font = UIFont.systemFont(ofSize: 20)
            shareLabel.adjustsFontSizeToFitWidth = true
            shareLabel.textColor = .white
            self.backView.addSubview(shareLabel)
            // 分别设置图片下文字和点击方法
            switch index {
            case 0:
                shareLabel.text = "编     辑"
                shareBtn.addTarget(self, action: #selector(self.tapped1), for: .touchUpInside)

            case 1:
                shareLabel.text = "效果展示"
                shareBtn.addTarget(self, action: #selector(self.tapped2), for: .touchUpInside)
            case 2:
                shareLabel.text = "替换图片"
                shareBtn.addTarget(self, action: #selector(self.tapped3), for: .touchUpInside)
            case 3:
                shareLabel.text = "一键线条"
                shareBtn.addTarget(self, action: #selector(self.tapped4(sender:)), for: .touchUpInside)
            default:
                shareLabel.text = "保存相册"
                shareBtn.addTarget(self, action: #selector(self.tapped5), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Methods
    
    @objc
    func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // let index = sender.selectedSegmentIndex
        print("[ZYJPhotoEditViewController] - [segmentedControlValueChanged]: " + "Segment.selectedSegmentIndex: \(sender.selectedSegmentIndex)")
    }
    
    @objc
    func lianjiePhoto() {
        let vc = BlueListVC()
        vc.backBlock = {
            if MHTBluetoothManager.shared().isConnected() {
                SVProgressHUD.showInfo(withStatus: "连接成功")
                SVProgressHUD.dismiss(withDelay: 0.5)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    func showConfirmationAlert() {
        let alertController = UIAlertController(title: "确认打印", message: "是否确认打印？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            print("取消打印")
        }
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            self.savePhoto()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc
    func savePhoto() {
        print("确认打印")
        // saveImageToPhotoAlbum(image: backImage.image!)
        // UIImageWriteToSavedPhotosAlbum(backImage.image!, nil, nil, nil)
        // return
        let saveImage = self.saveImageToPhotoAlbum(image: self.backImage.image!)
        // let saveImage = backImage.image
        if saveImage != nil {
            if MHTBluetoothManager.shared().isConnected() {
                print(self.backImage.image!)
                SVProgressHUD.showInfo(withStatus: "启动中")
                // SVProgressHUD.dismiss(withDelay: 3)
                // densityLevel: 0 shallow，1 light ，2 moderate ，3  normal ，4 strong
                let data = MHTPrintManage.shared.printImageParam(image: saveImage!, densityLevel: segmentControl.selectedSegmentIndex)
                MHTBluetoothManager.shared().write(data) { peripheral, state, error in
                    if state {
                        NSLog("writeData success")
                        SVProgressHUD.showInfo(withStatus: "打印中")
                        SVProgressHUD.dismiss(withDelay: 15)
                    } else {
                        SVProgressHUD.showInfo(withStatus: "打印失败,请重试")
                        SVProgressHUD.dismiss(withDelay: 1)
                    }
                }
            } else {
                SVProgressHUD.showInfo(withStatus: "蓝牙未连接")
                SVProgressHUD.dismiss(withDelay: 1)
            }
        } else {
            SVProgressHUD.showInfo(withStatus: "图片保存失败,请重试!")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }

    func saveImageToPhotoAlbum(image: UIImage) -> UIImage? {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)

        // 绘制白色背景
        UIColor.white.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        // 绘制原始图像
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

    /*
     func saveImageToPhotoAlbum(image: UIImage) -> UIImage? {
         let screenSize = UIScreen.main.bounds.size
         let view = UIView(frame: CGRect(origin: .zero, size: screenSize))
         view.backgroundColor = .white
         let imageView = UIImageView(image: image)
         imageView.contentMode = .scaleAspectFit
         imageView.frame = CGRect(x: (screenSize.width - image.size.width) / 2,
                                  y: (screenSize.height - image.size.height) / 2,
                                  width: image.size.width,
                                  height: image.size.height)
         view.addSubview(imageView)
         // 开始绘制
         UIGraphicsBeginImageContextWithOptions(screenSize, false, 0.0)
         view.layer.render(in: UIGraphicsGetCurrentContext()!)
         let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         UIImageWriteToSavedPhotosAlbum(renderedImage!, nil, nil, nil)
         return renderedImage
     }
     */

    @objc
    func tapped1() {
        self.navigationItem.rightBarButtonItems = [self.homeMineButton, self.lianjieButton]
        let borderWidth: CGFloat = 2.0
        let borderColor = UIColor.black
        let vc = ZYJSecondPhotoEditViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.returnSaveImageBlock = { [weak self] image in
            self?.backImage.image = image
            print(image)
        }
        if let borderedImage = addBorderToImage(image: backImage.image!, borderWidth: 0, borderColor: borderColor) {
            // 在这里使用带有边框的图片（borderedImage）
            // 例如，将其设置为 UIImageView 的图像：
            let imageView = UIImageView(image: borderedImage)
            vc.addImage = imageView.image!
            // vc.addImage = origialImage
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    func tapped2() {
        //        效果展示
        self.navigationItem.rightBarButtonItems = [self.homeMineButton, self.lianjieButton]

        ZYJAlert.showMemberActionSheet(title: "请选择", msg: nil, others: ["男", "女"], cancleTitle: "取消") { index in
            let vc = ZYJPhotoShowViewController()

            if index == "男" {
                vc.type = 1

            } else if index == "女" {
                vc.type = 2
            }
            vc.hidesBottomBarWhenPushed = true
            vc.showPhoto = self.backImage.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //        ZYJAlert.showSubmitAlert(title: "提示", msg: "请选择性别", submitTitle: "女", cancleTitle: "男") { index  in
        //
        //            let vc = ZYJPhotoShowViewController()
        //
        //            if index ==  0{
        //
        //                vc.type = 1
        //            }else{
        //                vc.type = 2
        //            }
        //
        //            vc.hidesBottomBarWhenPushed = true
        //            vc.showPhoto = self.backImage.image
        //            self.navigationController?.pushViewController(vc, animated: true)
        //
        //        }
    }

    @objc
    func tapped3() {
        self.navigationItem.rightBarButtonItems = [self.homeMineButton, self.lianjieButton]
        // 替换图片
        pushTZImagePickerController()
    }

    @objc
    func tapped4(sender: UIButton) {
        self.navigationItem.rightBarButtonItems = [self.baocunButton]

        // 一键线条
        sender.isSelected = !sender.isSelected

        if sender.isSelected == false {
            print("dianjisss")

            let icon = UIImageView()
            let url: URL? = URL(string: imgurl)
            self.backImage.kf.setImage(with: url)

            if self.type == "1" {
                self.backImage.image = self.pushSelectedPhotos[0]
            }
        } else {
            // let vc = OpenCVWrapper()
            // let resultImage = vc.performAdaptiveThreshold(on: backImage.image!)
            // backImage.image = resultImage

            let resultImage = OpenCVWrapper.performCannyEdgeDetection(with: self.backImage.image!)
            self.backImage.image = resultImage
            self.backImage.backgroundColor = .white
        }
    }

    @objc
    func tapped5() {
        self.navigationItem.rightBarButtonItems = [self.homeMineButton, self.lianjieButton]
        // 保存图片
        saveImage(image: self.backImage.image!)
    }

    func addBorderToImage(image: UIImage, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        let imageSize = image.size
        let scale = image.scale
        let borderSize = borderWidth * scale

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)

        // 绘制边框
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(borderSize)
        context.stroke(rect)

        // 绘制图片
        image.draw(in: rect.insetBy(dx: borderSize / 2, dy: borderSize / 2))

        guard let borderedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return borderedImage
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate

extension ZYJPhotoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate {
    func pushTZImagePickerController() {
        let imagePickerVc = TZImagePickerController(maxImagesCount: 10, columnNumber: 3, delegate: self, pushPhotoPickerVc: true)
        imagePickerVc?.selectedAssets = NSMutableArray(array: self.selectedAssets)
        imagePickerVc?.iconThemeColor = UIColor(red: 31 / 255.0, green: 185 / 255.0, blue: 34 / 255.0, alpha: 1.0)
        imagePickerVc?.showPhotoCannotSelectLayer = true
        imagePickerVc?.cannotSelectLayerColor = UIColor(white: 185 / 255.0, alpha: 0.8)
        imagePickerVc?.allowTakePicture = true
        imagePickerVc?.allowTakeVideo = false
        imagePickerVc?.allowPickingVideo = true // 不能选择视频
        imagePickerVc?.allowPickingOriginalPhoto = false // 选择原图
        imagePickerVc?.isSelectOriginalPhoto = true
        imagePickerVc?.allowPickingGif = false // 发送gif图片
        imagePickerVc?.allowPickingMultipleVideo = false
        imagePickerVc?.sortAscendingByModificationDate = false // 照片排列按修改时间升序
        imagePickerVc?.showSelectBtn = false
        imagePickerVc?.allowCrop = false // 剪裁图片
        imagePickerVc?.showSelectedIndex = true // 显示选择照片数
        imagePickerVc?.modalPresentationStyle = .fullScreen
        self.present(imagePickerVc!, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //        SVProgressHUD.show()

        picker.dismiss(animated: true)
        let type = info[.mediaType] as? String
        switch type {
        case "public.image":
            let image = info[.originalImage] as! UIImage
            TZImageManager.default()?.savePhoto(with: image, completion: { [weak self] asset, error in
                if error != nil {
                    print(error.debugDescription)
                } else {
                    if let tempAsset = asset {
                        self?.selectedPhotos.append(image)
                        self?.selectedAssets.append(tempAsset)
                    }
                }
            })
        default:
            break
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable: Any]]!) {
        //        SVProgressHUD.show()
        self.selectedPhotos = photos!
        self.selectedAssets = assets!
        self.backImage.image = self.selectedPhotos[0]
    }

    @objc
    func savetapped5() {
        //        保存图片
        self.saveImage(image: self.backImage.image!)
        self.navigationController?.popViewController(animated: true)
    }

    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        picker.dismiss(animated: true)
    }

    /// 保存相册
    func saveImage(image: UIImage) {
        print("图片--->\(image)")
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            SVProgressHUD.showInfo(withStatus: "保存失败,请稍后再试!")
            SVProgressHUD.dismiss(withDelay: 0.5)
            print("保存失败")
            return
        }
        SVProgressHUD.showInfo(withStatus: "已保存在相册")
        SVProgressHUD.dismiss(withDelay: 0.5)
    }

    func lineDrawing(image: UIImage) -> UIImage? {
        let blackAndWhiteImage = self.convertToBlackAndWhiteWithoutShadows(image: image)
        // 使用转换后的黑白图像
        // ...

        let context = CIContext(options: nil)

        guard let cgImage = blackAndWhiteImage?.cgImage else {
            return nil
        }
        let ciImage = CIImage(cgImage: cgImage)
        let parameters = [
            "inputContrast": 50,
            "inputThreshold": 1.00, // 线条数量
            "inputNRNoiseLevel": 1.00, // 填充颜色
            "inputNRSharpness": 1.5, // 清晰度
            "inputEdgeIntensity": 1.5,
        ]
        guard let filter = CIFilter(name: "CILineOverlay", parameters: parameters) else {
            return nil
        }

        print("filter.inputKeys：", filter.inputKeys)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else {
            return nil
        }
        guard let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImageResult)
    }

    func convertToBlackAndWhiteWithoutShadows(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        // 转换为灰度图像
        guard let grayFilter = CIFilter(name: "CIColorControls") else {
            return nil
        }
        grayFilter.setValue(ciImage, forKey: kCIInputImageKey)
        grayFilter.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let grayImage = grayFilter.outputImage else {
            return nil
        }

        // 移除阴影
        guard let exposureFilter = CIFilter(name: "CIExposureAdjust") else {
            return nil
        }
        exposureFilter.setValue(grayImage, forKey: kCIInputImageKey)
        exposureFilter.setValue(3.0, forKey: kCIInputEVKey)
        guard let outputImage = exposureFilter.outputImage else {
            return nil
        }

        let context = CIContext(options: nil)

        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            return processedImage
        }

        return nil
    }
}

//    "inputContrast": 50,
//    "inputThreshold": 3, //线条数量
//    "inputNRNoiseLevel":2.0,//填充颜色
//    "inputNRSharpness":1, //清晰度
//    "inputEdgeIntensity":2 //强度 数字越大 彩色图片线条黑色更多
//
//    "inputContrast": 50,
//    "inputThreshold": 0.8, //线条数量
//    "inputNRNoiseLevel":1.00,//填充颜色
//    "inputNRSharpness":0.5, //清晰度
//    "inputEdgeIntensity":1.5//强度 数字越大 彩色图片线条黑色更多
//
//    "inputContrast": 50,
//    "inputThreshold": 0.8,
//    "inputNRNoiseLevel":0.5,
//    "inputNRSharpness":9, //清晰度
//    "inputEdgeIntensity":1.5 //强度 数字越大 彩色图片线条黑色更多
