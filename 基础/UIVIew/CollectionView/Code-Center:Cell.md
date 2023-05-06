##### 自定义FlowLayout:

```
class CenterCollectFlowLayout: UICollectionViewFlowLayout {
        
    override func prepare() {
        scrollDirection = .horizontal
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        guard let `collectionView` = collectionView, let attributes = attributes else {
            return attributes
        }
        var newAttrubtArr: [UICollectionViewLayoutAttributes] = []
        let x = collectionView.contentOffset.x + collectionView.bounds.size.width / 2
        for attribute in attributes {
            // 移动的距离和屏幕宽度的的比例
            let apartScale = abs(attribute.center.x - x) / collectionView.bounds.size.width
            // 把卡片移动范围固定到 -π/4到 +π/4这一个范围内
            let scale = abs(cos(apartScale * CGFloat.pi / 4))
            // 设置cell的缩放 按照余弦函数曲线 越居中越趋近于1
            attribute.transform = CGAffineTransform(scaleX: 1.0, y: scale)
            //
            newAttrubtArr.append(attribute)
        }
        return newAttrubtArr
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: self.collectionView?.frame.width ?? 0, height: self.collectionView?.frame.height ?? 0)
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        var minpace: CGFloat = CGFloat(MAXFLOAT)
        let centerX = proposedContentOffset.x + (self.collectionView?.frame.width ?? 0) * 0.5
        for attribute in attributes {
            if abs(attribute.center.x - centerX) < abs(minpace) {
                minpace = attribute.center.x - centerX
            }
        }
        return CGPoint(x: proposedContentOffset.x + minpace, y: proposedContentOffset.y)
    }
}
```



##### 设置第一个与最后一个Cell的偏移UIEdgeInsets:

```
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
}
```

