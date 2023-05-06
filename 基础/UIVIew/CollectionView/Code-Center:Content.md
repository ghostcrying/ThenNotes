## 居中显示Content

- Method:
  - set each cell's offset

```
final class Layout: UICollectionViewFlowLayout {
    // calculate and use in function: collectionViewContentSize 
    private var contentRect: CGRect = .zero
    // save every UICollectionViewLayoutAttributes, and use in layoutAttributesFor...
    private var itemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    // init
    init(direction: UICollectionView.ScrollDirection = .vertical) {
        super.init()
        scrollDirection = direction
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .vertical
    }
    //* 内容尺寸
    override var collectionViewContentSize: CGSize {
        return contentRect.size
    }

    //* prepare方法被自动调用，以保证layout实例的正确
    override func prepare() {
        super.prepare()

        itemAttributes.removeAll()
        contentRect = .zero

        guard let `collectionView` = collectionView, let dataSource = collectionView.dataSource else {
            return
        }

        let rect = collectionView.bounds.inset(by: collectionView.contentInset)

        let insets = UIEdgeInsets(top: 0, left: 12.pt.autoScaleMax, bottom: 0, right: 12.pt.autoScaleMax)
        let renderRect = rect.inset(by: insets)

        let columns: Int = 3
        let space: CGFloat = 16.pt.autoScaleMax
        let innerSpace: CGFloat = 12.pt.autoScaleMax
        let width = ((renderRect.width - innerSpace * CGFloat(columns - 1)) / CGFloat(columns)).pt.floor
        let height = width * 80.0 / 96.0

        let items = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)

        guard items > 0 else { return }

        var point = CGPoint(x: renderRect.minX, y: renderRect.minY)

        for item in (0..<items) {

            if point.x + innerSpace + width > renderRect.maxX {
                point.x = renderRect.minX
                point.y += space + height
            }

            let indexPath = IndexPath(item: item, section: 0)
            let itemAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttribute.frame = CGRect(x: point.x , y: point.y, width: width, height: height)
            itemAttributes[indexPath] = itemAttribute

            point.x += width

            contentRect = contentRect.union(itemAttribute.frame)
        }
        
        //* set offset to show content in center.
        let offsetX = max(0, (renderRect.width - contentRect.width) / 2.0)
        let offsetY = max(0, (renderRect.height - contentRect.height) / 2.0)
        //* set each cell's offset
        itemAttributes.forEach {
            $0.value.center = CGPoint(x: $0.value.center.x + offsetX, y: $0.value.center.y + offsetY)
        }
        //* calculate the real contentSize
        contentRect.size = CGSize(width: max(collectionView.bounds.width, contentRect.width), height: max(collectionView.bounds.height, contentRect.height))
    }
    //* total attributes(所有布局属性)
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributes.compactMap { $0.value }
    }
    //* every attribute(对应indexpath的布局属性)
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath]
    }
    //* 返回对应于indexPath的位置的追加视图的布局属性，如果没有追加视图可不重载
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    //* 返回对应于indexPath的位置的装饰视图的布局属性，如果没有装饰视图可不重载
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return nil
        }
    //* 当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息调用顺序
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
```





- 保持少量的Cell居中

```
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let totalCellWidth = 128 * count
    let totalSpacingWidth = 12 * (count - 1)
    let totalWidth = totalCellWidth + totalSpacingWidth
    let leftInset = (UIScreen.main.bounds.size.width - CGFloat(totalWidth)) / 2
    if (leftInset > 0) {
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
    }
    return UIEdgeInsets()
}
```

