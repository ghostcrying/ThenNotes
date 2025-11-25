

```
func pixelBufferToImage(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    //01
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    //02
    defer {
       CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
        
    //03
    let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
    //04
    let lumaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
    let lumaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
    let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
    var sourceLumaBuffer = vImage_Buffer(data: lumaBaseAddress, height: vImagePixelCount(lumaHeight), width: vImagePixelCount(lumaWidth), rowBytes: lumaRowBytes)
        
    let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
    let chromaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
    let chromaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
    let chromaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)
    var sourceChromaBuffer = vImage_Buffer(data: chromaBaseAddress, height: vImagePixelCount(chromaHeight), width: vImagePixelCount(chromaWidth), rowBytes: chromaRowBytes)
        
    //05
    let rawRGBBuffer: UnsafeMutableRawPointer = malloc(lumaWidth * lumaHeight * 4)
    var rgbBuffer: vImage_Buffer = vImage_Buffer(data: rawRGBBuffer, height: vImagePixelCount(lumaHeight), width: vImagePixelCount(lumaWidth), rowBytes: lumaWidth * 4)
        
    //06
    guard var conversionInfoYpCbCrToARGB = _conversionInfoYpCbCrToARGB else {
        return UIImage()
    }
        
    //07
    guard vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer, &sourceChromaBuffer, &rgbBuffer, &conversionInfoYpCbCrToARGB, nil, 255, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
        return UIImage()
    }
      
    //08
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: rgbBuffer.data, width: lumaWidth, height: lumaHeight, bitsPerComponent: 8, bytesPerRow: rgbBuffer.rowBytes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    let imageRef = ctx!.makeImage()!
    let uiimage = UIImage(cgImage: imageRef)
       
    //09
    rawRGBBuffer.deallocate()
    return uiimage
}

private var _conversionInfoYpCbCrToARGB: vImage_YpCbCrToARGB? = {
    var pixelRange = vImage_YpCbCrPixelRange(Yp_bias: 16, CbCr_bias: 128, YpRangeMax: 235, CbCrRangeMax: 240, YpMax: 235, YpMin: 16, CbCrMax: 240, CbCrMin: 16)
    var infoYpCbCrToARGB = vImage_YpCbCrToARGB()
    guard vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4!, &pixelRange, &infoYpCbCrToARGB, kvImage422CbYpCrYp8, kvImageARGB8888, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
        return nil
    }
    return infoYpCbCrToARGB
}()

```



```
func pixelBufferToImage(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    // 01
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    // 02
    defer {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    }
        
    // 03
    let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
    // 04
    let lumaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
    let lumaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
    let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
    var sourceLumaBuffer = vImage_Buffer(data: lumaBaseAddress, height: vImagePixelCount(lumaHeight), width: vImagePixelCount(lumaWidth), rowBytes: lumaRowBytes)
        
    let chromaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
    let chromaWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
    let chromaHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
    let chromaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)
    var sourceChromaBuffer = vImage_Buffer(data: chromaBaseAddress, height: vImagePixelCount(chromaHeight), width: vImagePixelCount(chromaWidth), rowBytes: chromaRowBytes)
        
    // 05
    let rawRGBBuffer: UnsafeMutableRawPointer = malloc(lumaWidth * lumaHeight * 4)
    var rgbBuffer = vImage_Buffer(data: rawRGBBuffer, height: vImagePixelCount(lumaHeight), width: vImagePixelCount(lumaWidth), rowBytes: lumaWidth * 4)
        
    // 06
    guard var conversionInfoYpCbCrToARGB = _conversionInfoYpCbCrToARGB else {
        return nil
    }
        
    // 07
    guard vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer, &sourceChromaBuffer, &rgbBuffer, &conversionInfoYpCbCrToARGB, nil, 255, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
        return nil
    }
      
    // 08
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: rgbBuffer.data, width: lumaWidth, height: lumaHeight, bitsPerComponent: 8, bytesPerRow: rgbBuffer.rowBytes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    guard let imageRef = ctx?.makeImage() else {
        rawRGBBuffer.deallocate()
        return nil
    }
        
    // 创建 CIImage 而不是 UIImage
    let ciImage = CIImage(cgImage: imageRef)
    // 09
    rawRGBBuffer.deallocate()
    return ciImage
}

private var _conversionInfoYpCbCrToARGB: vImage_YpCbCrToARGB? = {
    var pixelRange = vImage_YpCbCrPixelRange(Yp_bias: 16, CbCr_bias: 128, YpRangeMax: 235, CbCrRangeMax: 240, YpMax: 235, YpMin: 16, CbCrMax: 240, CbCrMin: 16)
    var infoYpCbCrToARGB = vImage_YpCbCrToARGB()
    guard vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4!, &pixelRange, &infoYpCbCrToARGB, kvImage422CbYpCrYp8, kvImageARGB8888, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
        return nil
    }
    return infoYpCbCrToARGB
}()

func rotatedPixelBuffer(from ciImage: CIImage, orientation: AVCaptureVideoOrientation) -> CVPixelBuffer? {
    let srcW = Int(ciImage.extent.width)
    let srcH = Int(ciImage.extent.height)
    
    var outW = srcW
    var outH = srcH
    var exif: Int32 = 1
    
    switch orientation {
    case .portrait:           exif = 1; outW = srcW; outH = srcH
    case .portraitUpsideDown: exif = 3; outW = srcW; outH = srcH
    case .landscapeLeft:      exif = 6; outW = srcH; outH = srcW // 逆时针 90
    case .landscapeRight:     exif = 8; outW = srcH; outH = srcW // 顺时针 90
    default: exif = 1
    }
    
    var pixelBuffer: CVPixelBuffer?
    let attrs = [
        kCVPixelBufferCGImageCompatibilityKey: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        kCVPixelBufferMetalCompatibilityKey: true
    ] as CFDictionary
    
    let status = CVPixelBufferCreate(kCFAllocatorDefault, outW, outH,
                                     kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
    guard status == kCVReturnSuccess, let pb = pixelBuffer else { return nil }
    
    let orientedImage = ciImage.oriented(forExifOrientation: exif)
    
    let ciContext = CIContext()
    CVPixelBufferLockBaseAddress(pb, [])
    ciContext.render(orientedImage, to: pb)
    CVPixelBufferUnlockBaseAddress(pb, [])
    
    return pb
}
```



```
                if let image = pixelBufferToImage(sampleBuffer), let buffer = rotatedPixelBuffer(from: image, orientation: self?.currentPreviewOrientation ?? .portrait) {
                    // self?.processFrame(pixelBuffer: buffer)
                    if self?.currentPreviewOrientation == .landscapeLeft {
                        self?.saveImageToLocal(buffer)
                    }
```

