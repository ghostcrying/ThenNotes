## CGRect

#### inset 

```
let origin = CGRect(x: 100, y: 100, width: 100, height: 50)

print(origin.inset(by: UIEdgeInsets(-20)))
print(origin.insetBy(dx: -20, dy: -20))
/// (80.0, 80.0, 140.0, 90.0)

print(origin.inset(by: UIEdgeInsets(20)))
print(origin.insetBy(dx: 20, dy: 20))
/// (120.0, 120.0, 60.0, 10.0)
```

- 规则

  > 以中心为基准, xy轴进行扩展, 正值压缩, 负值扩展
  >
  > width = origin.width - dx*2
  >
  > height = origin.height -dy*2
  >
  > x = origin.x + dx
  >
  > y = origin.y + dy

