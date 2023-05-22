# UITextView



#### NSUndoManager

> UITextField&UITextView通用

> Undo与Redo是成对出现, 否则会出现Redo不生效问题

```
var text: NSAttributedString?
NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: input, queue: .main) { [weak self] noti in
    guard let `self` = self else { return }
    let text = (noti.object as? UITextView)?.attributedText
    let oldtext = self.text
    guard oldtext != text else {
        return
    }
    self.text = text
    /// Undo与Redo是成对出现, 否则会出现Redo不生效问题
    // undo
    self.undoManager?.registerUndo(withTarget: self, handler: { t1 in
        t1.text = oldtext
        self.input.attributedText = oldtext
        // redo
        self.undoManager?.registerUndo(withTarget: self, handler: { t2 in
            self.text = text
            t2.input.attributedText = text
        })
    })
}
```

针对Html样式的输入编辑框(文本&图片&视图), 可以参照

- https://github.com/rajdeep/proton
