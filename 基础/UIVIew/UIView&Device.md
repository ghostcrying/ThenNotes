# iPhone Device



#### **[所有机型](https://www.theiphonewiki.com/wiki/Models)**

#### 像素

```
机型                     屏幕尺寸      逻辑分辨率pt  设备分辨率px   缩放因子 (Scale)   像素密度ppi
4                       3.5          320x480     640x960       @2x              326
5(s/se)                 4.0          320×568     640×1136      @2x              326
6(s)/7/8/se2            4.7          375×667     750×1334      @2x              326
6 Plus/7 Plus/8 Plus    5.5          414×736     1242×2208     @3x              401
X/XS/11 Pro             5.8          375×812     1125×2436     @3x              458
XR/11                   6.1          414×896     828×1792      @2x              326
XS Max/11 Pro Max       6.5          414×896     1242×2688     @3x              458
12 mini                 5.4          375×812     1080×2340     @3x              467
12/12 Pro/13/13 Pro     6.1          390×844     1170×2532     @3x              460
12/13 Pro Max           6.7          428×926     1284×2778     @3x              458
14                      6.1          390x844     1170x2532     @3x              460
14 Plus                 6.7          428x926     1284x2778     @3x              458
14 Pro                  6.1          393x852     1179x2556     @3x              460
14 Pro Max              6.7          430x932     1290x2796     @3x              460
```

#### 状态栏高度

```
- iOS14前，iPhone状态栏高度只有两种，刘海屏44pt，非刘海屏20pt。
- iOS14后，刘海屏的状态栏高度不再是固定的44pt。
最新iPhone各屏幕状态栏高度如下：
机型	                            高度（pt）
iPhone 11/XR	                    48
iPhone 12/12 Pro/13/13 Pro/14	    47
iPhone 14 Pro/14 Pro Max	        59
iphone	                          44
iphone 8 low	                    20

// 导航栏高度
```

#### 机型代码

```
/// Enum representing the different types of iOS devices available
public enum DeviceType: String, CaseIterable {
    
    case iPhone2G

    case iPhone3G
    case iPhone3GS

    case iPhone4
    case iPhone4S

    case iPhone5
    case iPhone5C
    case iPhone5S

    case iPhone6
    case iPhone6Plus

    case iPhone6S
    case iPhone6SPlus

    case iPhoneSE
    case iPhoneSE2
    case iPhoneSE3

    case iPhone7
    case iPhone7Plus

    case iPhone8
    case iPhone8Plus
    
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax

    case iPhone12mini
    case iPhone12
    case iPhone12Pro
    case iPhone12ProMax
    
    case iPhone13mini
    case iPhone13
    case iPhone13Pro
    case iPhone13ProMax
    
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14ProMax
    
    case iPhoneX
    case iPhoneXR
    case iPhoneXS
    case iPhoneXSMax

    case iPodTouch1
    case iPodTouch2
    case iPodTouch3
    case iPodTouch4
    case iPodTouch5
    case iPodTouch6
    case iPodTouch7

    case iPad
    case iPad2
    case iPad3
    case iPad4
    case iPad5
    case iPad6
    case iPad7
    case iPad8
    case iPad9
    
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadMini5
    case iPadMini6

    case iPadAir
    case iPadAir2
    case iPadAir3
    case iPadAir4
    case iPadAir5

    case iPadPro9Inch
    case iPadPro10Inch
    case iPadPro11Inch
    case iPadPro11Inch2
    case iPadPro11Inch3
    case iPadPro12Inch
    case iPadPro12Inch2
    case iPadPro12Inch3
    case iPadPro12Inch4
    case iPadPro12Inch5

    case simulator
    case notAvailable
    
}

extension DeviceType {
    
    // MARK: Inits

    /// Creates a device type
    ///
    /// - Parameter identifier: The identifier of the device
    public init(identifier: String) {

        for device in DeviceType.allCases {
            for deviceId in device.identifiers {
                guard identifier == deviceId else { continue }
                self = device
                return
            }
        }
        
        self = .notAvailable
    }
    
    // MARK: Constants

    /// The current device type
    public static var current: DeviceType {

        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""

        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }

        return DeviceType(identifier: identifier)
    }

    // MARK: Variables

    /// The display name of the device type
    public var displayName: String {

        switch self {
            
        case .iPhone2G: return "iPhone 2G"
        case .iPhone3G: return "iPhone 3G"
        case .iPhone3GS: return "iPhone 3GS"
            
        case .iPhone4: return "iPhone 4"
        case .iPhone4S: return "iPhone 4S"
            
        case .iPhone5: return "iPhone 5"
        case .iPhone5C: return "iPhone 5C"
        case .iPhone5S: return "iPhone 5S"
            
        case .iPhone6Plus:  return "iPhone 6 Plus"
        case .iPhone6:      return "iPhone 6"
        case .iPhone6S:     return "iPhone 6S"
        case .iPhone6SPlus: return "iPhone 6S Plus"
            
        case .iPhoneSE:  return "iPhone SE"
        case .iPhoneSE2: return "iPhone SE 2nd"
        case .iPhoneSE3: return "iPhone SE 3nd"
            
        case .iPhone7:     return "iPhone 7"
        case .iPhone7Plus: return "iPhone 7 Plus"
            
        case .iPhone8:     return "iPhone 8"
        case .iPhone8Plus: return "iPhone 8 Plus"
            
        case .iPhone11:       return "iPhone 11"
        case .iPhone11Pro:    return "iPhone 11 Pro"
        case .iPhone11ProMax: return "iPhone 11 Pro Max"
            
        case .iPhone12mini:   return "iPhone 12 mini"
        case .iPhone12:       return "iPhone 12"
        case .iPhone12Pro:    return "iPhone 12 Pro"
        case .iPhone12ProMax: return "iPhone 12 Pro Max"
            
        case .iPhone13mini:   return "iPhone 13 mini"
        case .iPhone13:       return "iPhone 13"
        case .iPhone13Pro:    return "iPhone 13 Pro"
        case .iPhone13ProMax: return "iPhone 13 Pro Max"
                        
        case .iPhone14:       return "iPhone 14"
        case .iPhone14Plus:   return "iPhone 14 Plus"
        case .iPhone14Pro:    return "iPhone 14 Pro"
        case .iPhone14ProMax: return "iPhone 14 Pro Max"
            
        case .iPhoneX:     return "iPhone X"
        case .iPhoneXS:    return "iPhone XS"
        case .iPhoneXSMax: return "iPhone XS Max"
            
        case .iPhoneXR: return "iPhone XR"
            
        case .iPodTouch1: return "iPod Touch 1"
        case .iPodTouch2: return "iPod Touch 2"
        case .iPodTouch3: return "iPod Touch 3"
        case .iPodTouch4: return "iPod Touch 4"
        case .iPodTouch5: return "iPod Touch 5"
        case .iPodTouch6: return "iPod Touch 6"
        case .iPodTouch7: return "iPod Touch 7"
            
        case .iPad: return "iPad"
        case .iPad2: return "iPad 2"
        case .iPad3: return "iPad 3rd"
        case .iPad4: return "iPad 4th"
        case .iPad5: return "iPad 5th"
        case .iPad6: return "iPad 6th"
        case .iPad7: return "iPad 7th"
        case .iPad8: return "iPad 8th"
        case .iPad9: return "iPad 9th"
            
        case .iPadMini: return "iPad Mini"
        case .iPadMini2: return "iPad Mini 2"
        case .iPadMini3: return "iPad Mini 3"
        case .iPadMini4: return "iPad Mini 4"
        case .iPadMini5: return "iPad Mini 5th"
        case .iPadMini6: return "iPad Mini 6th"
            
        case .iPadAir: return "iPad Air"
        case .iPadAir2: return "iPad Air 2"
        case .iPadAir3: return "iPad Air 3rd"
        case .iPadAir4: return "iPad Air 4th"
        case .iPadAir5: return "iPad Air 5th"
            
        case .iPadPro9Inch: return "iPad Pro 9 Inch"
        case .iPadPro10Inch: return "iPad Pro 10.5 Inch"
        case .iPadPro11Inch: return "iPad Pro 11 Inch"
        case .iPadPro11Inch2: return "iPad Pro 11 Inch 2nd"
        case .iPadPro11Inch3: return "iPad Pro 11 Inch 3rd"
        case .iPadPro12Inch: return "iPad Pro 12 Inch"
        case .iPadPro12Inch2: return "iPad Pro 12 Inch 2nd"
        case .iPadPro12Inch3: return "iPad Pro 12 Inch 3rd"
        case .iPadPro12Inch4: return "iPad Pro 12 Inch 4th"
        case .iPadPro12Inch5: return "iPad Pro 12 Inch 5th"
            
        case .simulator: return "Simulator"
        case .notAvailable: return "Not Available"        }
    }

    /// The identifiers associated with each device type
    public var identifiers: [String] {

        switch self {
        case .notAvailable: return []
        case .simulator:    return ["i386", "x86_64"]

        case .iPhone2G:  return ["iPhone1,1"]
        case .iPhone3G:  return ["iPhone1,2"]
        case .iPhone3GS: return ["iPhone2,1"]
            
        case .iPhone4:  return ["iPhone3,1", "iPhone3,2", "iPhone3,3"]
        case .iPhone4S: return ["iPhone4,1"]
            
        case .iPhone5:  return ["iPhone5,1", "iPhone5,2"]
        case .iPhone5C: return ["iPhone5,3", "iPhone5,4"]
        case .iPhone5S: return ["iPhone6,1", "iPhone6,2"]
            
        case .iPhone6:     return ["iPhone7,2"]
        case .iPhone6Plus: return ["iPhone7,1"]
            
        case .iPhone6S:     return ["iPhone8,1"]
        case .iPhone6SPlus: return ["iPhone8,2"]
            
        case .iPhoneSE:  return ["iPhone8,4"]
        case .iPhoneSE2: return ["iPhone12,8"]
        case .iPhoneSE3: return ["iPhone14,6"]
            
        case .iPhone7:     return ["iPhone9,1", "iPhone9,3"]
        case .iPhone7Plus: return ["iPhone9,2", "iPhone9,4"]
            
        case .iPhone8:     return ["iPhone10,1", "iPhone10,4"]
        case .iPhone8Plus: return ["iPhone10,2", "iPhone10,5"]
            
        case .iPhoneX:     return ["iPhone10,3", "iPhone10,6"]
        case .iPhoneXS:    return ["iPhone11,2"]
        case .iPhoneXSMax: return ["iPhone11,4", "iPhone11,6"]
            
        case .iPhoneXR: return ["iPhone11,8"]
            
        case .iPhone11:       return ["iPhone12,1"]
        case .iPhone11Pro:    return ["iPhone12,3"]
        case .iPhone11ProMax: return ["iPhone12,5"]
            
        case .iPhone12mini:   return ["iPhone13,1"]
        case .iPhone12:       return ["iPhone13,2"]
        case .iPhone12Pro:    return ["iPhone13,3"]
        case .iPhone12ProMax: return ["iPhone13,4"]
            
        case .iPhone13mini:   return ["iPhone14,4"]
        case .iPhone13:       return ["iPhone14,5"]
        case .iPhone13Pro:    return ["iPhone14,2"]
        case .iPhone13ProMax: return ["iPhone14,3"]

        case .iPhone14:       return ["iPhone14,7"]
        case .iPhone14Plus:   return ["iPhone14,8"]
        case .iPhone14Pro:    return ["iPhone15,2"]
        case .iPhone14ProMax: return ["iPhone15,3"]
            
        case .iPodTouch1: return ["iPod1,1"]
        case .iPodTouch2: return ["iPod2,1"]
        case .iPodTouch3: return ["iPod3,1"]
        case .iPodTouch4: return ["iPod4,1"]
        case .iPodTouch5: return ["iPod5,1"]
        case .iPodTouch6: return ["iPod7,1"]
        case .iPodTouch7: return ["iPod9,1"]

        case .iPad:  return ["iPad1,1", "iPad1,2"]
        case .iPad2: return ["iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4"]
        case .iPad3: return ["iPad3,1", "iPad3,2", "iPad3,3"]
        case .iPad4: return ["iPad3,4", "iPad3,5", "iPad3,6"]
        case .iPad5: return ["iPad6,11", "iPad6,12"]
        case .iPad6: return ["iPad7,5", "iPad7,6"]
        case .iPad7: return ["iPad7,11", "iPad7,12"]
        case .iPad8: return ["iPad11,6", "iPad11,7"]
        case .iPad9: return ["iPad12,1", "iPad12,2"]
            
        case .iPadMini:  return ["iPad2,5", "iPad2,6", "iPad2,7"]
        case .iPadMini2: return ["iPad4,4", "iPad4,5", "iPad4,6"]
        case .iPadMini3: return ["iPad4,7", "iPad4,8", "iPad4,9"]
        case .iPadMini4: return ["iPad5,1", "iPad5,2"]
        case .iPadMini5: return ["iPad11,1", "iPad11,2"]
        case .iPadMini6: return ["iPad14,1", "iPad14,2"]
            
        case .iPadAir:  return ["iPad4,1", "iPad4,2", "iPad4,3"]
        case .iPadAir2: return ["iPad5,3", "iPad5,4"]
        case .iPadAir3: return ["iPad11,3", "iPad11,4"]
        case .iPadAir4: return ["iPad13,1", "iPad13,2"]
        case .iPadAir5: return ["iPad13,16", "iPad13,17"]
            
        case .iPadPro9Inch:   return ["iPad6,3", "iPad6,4"]
        case .iPadPro10Inch:  return ["iPad7,3", "iPad7,4"]
        case .iPadPro11Inch:  return ["iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4"]
        case .iPadPro11Inch2: return ["iPad8,9", "iPad8,10"]
        case .iPadPro11Inch3: return ["iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7"]
        case .iPadPro12Inch:  return ["iPad6,7", "iPad6,8"]
        case .iPadPro12Inch2: return ["iPad7,1", "iPad7,2"]
        case .iPadPro12Inch3: return ["iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8"]
        case .iPadPro12Inch4: return ["iPad8,11", "iPad8,12"]
        case .iPadPro12Inch5: return ["iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11"]
        }
    }
}
```

