# UILabel



## 富文本

##### 行数

```
link: https://stackoverflow.com/questions/28108745/how-to-find-actual-number-of-lines-of-uilabel) 
let width: CGFloat = 200
let font: UIFont = .systemFont(ofSize: 14)
let text: String = (0..<Int.random(in: 5..<100))
    .map { _ in
        ["🐶", "🐣"].randomElement() ?? "🐭"
    }
    .joined()
/// 当然同样也可以增加NSMutableParagraphStyle属性
let size = (text as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil)
//
let lines = Int(ceil(size.height / font.lineHeight))
```

##### 最后一行

```
link: https://stackoverflow.com/questions/57051804/how-can-i-calculate-the-last-line-width-of-label
extension NSAttributedString {
    /// last line width
    func lastlineWidth(_ attributeWidth: CGFloat) -> CGFloat {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let labelSize = CGSize(width: attributeWidth, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: labelSize)
        let textStorage = NSTextStorage(attributedString: self)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex, effectiveRange: nil)

        return lastLineFragmentRect.maxX
    }   
}
```

##### 点击富文本

```
extension UITapGestureRecognizer {
    
    /// 点击富文本中标记文本
    func tapAttributedText(label: UILabel, tapTexts: [String], completion: @escaping (String, Int) -> ()) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width)*0.5 - textBoundingBox.origin.x,
                                          y:(labelSize.height - textBoundingBox.size.height)*0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        
        if label.text == nil {
            return
        }
        
        for e in tapTexts.enumerated() {
            let targetRange: NSRange = (label.text! as NSString).range(of: e.element)
            let isContain = NSLocationInRange(indexOfCharacter, targetRange)
            if isContain {
                completion(e.element, e.offset)
            }
        }
    }
}
```

