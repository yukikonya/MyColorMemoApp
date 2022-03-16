//
//  MemoDetailViewController.swift
//  MyColorMemoApp
//
//  Created by YUKI の MacBook Pro on 2022/02/19.
//

import UIKit
// 14-4.では早速この保存処理を加えていく
import RealmSwift

class MemoDetailViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    // 14-.2この二つのプロパティをメモデータモデルに書き換えてあげる
//    var text: String = ""
//    var recordDate: Date = Date()
    // そうするとプロパティを変更したことによってクラス内にコンパイルエラーが発生するのでそれぞれ解消する
    // これは単にメモデータプロパティを使用した形式に書き換えてあげるだけでOK
    // これでエラーが解消された。これでメモデータモデルをこのクラス内で使用できるようになったのでデータ保存メソッドの作成を続けていく
    var memoData = MemoDataModel()
    
    // コンピューティッドプロパティ
    var dateFormat: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayData()
        // 10-8.キーボードに閉じるボタンを追加するメソッドを追加→実際にアプリを実行して挙動を確認
        setDoneButton()
        // 14-7.次にUITextViewデリゲートを準拠させた際にはTextViewのデリゲートプロパティに自身のクラスを代入することを忘れないように
        // これで文字列が書き変わるたびにデータの保存がされるようになった
        textView.delegate = self
    }
    
    func configure(memo: MemoDataModel) {
        memoData.text = memo.text
        memoData.recordDate = memo.recordDate
    }
    
    func displayData() {
        textView.text = memoData.text
        navigationItem.title = dateFormat.string(from: memoData.recordDate)
    }
    
    // 10-7.このtapDoneButtonメソッドは先ほどのヘッダーに表示したメモ追加ボタンのアクションの時と同じように後からセレクタークラスに指定するので＠objcキーワードを付与している
    @objc func tapDoneButton() {
        // 現在表示されているキーボードを閉じるという処理
        view.endEditing(true)
    }
    
    // 10-7.setDoneButtonメソッドは、キーボードに閉じるボタンを追加するためのメソッド
    func setDoneButton() {
        // まずはUIToolbarクラスをインスタンス化している。これはキーボードの上部にボタンを配置するためのツールバークラスとなっている
        // ここではコードを使ってUIを生成するためインスタンス化する際に幅や高さを指定している
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // 次にここではキーボードを閉じるためのボタンを作成している
        // 先ほどと同様にUIBarButtonItemに対してbarButtonSystem(Style?)Itemにdoneという種別を指定し、actionにはselectorのtapDoneButtonメソッドを指定している
        let commitButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDoneButton))
        // そしてここで作成したボタンをtoolBarのプロパティであるitemsに代入している
        // これでtoolBarに表示するボタンを作成できた
        // この時、toolBarには複数のUIコンポーネントを格納できるので配列形式で代入してあげる
        toolBar.items = [commitButton]
        // 最後に作成したtoolBarをUItextViewクラスのinputAccessoryViewに代入することでキーボード上のツールバーとしてボタンを表示させることができる
        // これでキーボードに閉じるボタンを追加できるのでこのメソッドをviewDidLoad内で実行してあげる
        textView.inputAccessoryView = toolBar
    }

    // 14-1.Realmを使ったデータ保存処理
    // まずはメモ詳細画面内でデータを保存するためのメソッドを追加していく
    // 保存するのはRealmのデータモデルであるMemoDataModelとなるがこのMemoDetailViewControllerクラス内ではモデルのプロパティが存在しないためプロパティの書き換えが必要になる。
    // 14-8.だがこのままだと書き換え後の文字列がメモデータプロパティに反映されないため入力された文字列で上書きをするようにする
    //func saveData() {
    func saveData(with text: String) {
        // 14-3.まずはRealmのドキュメントからデータの保存方法を確認する。
        // データを保存する際にはまずこのようにRealmクラスをインスタンス化しているがこの時にTryというキーワードが使われている
        // これはSwiftのエラー処理に関する構文だが、現時点ではこれを付与するルールになっているという理解でOK
        // この先もう少しSwiftの理解が深まったらもう一度調べてみる。
        // let realm = try! Realm()
        // ではデータモデルを保存する処理についてだが、このようにRealmのwriteメソッド内でaddメソッドを実行し、その際に保存したいデータを引数をして渡してあげればOK
        // try! realm.write { realm.add(myDog) }
        // 14-5.では早速この保存処理を加えていく
        // これでデータを保存するメソッドが定義できた
        let realm = try! Realm()
        try! realm.write {
            // 14-9.
            memoData.text = text
            // 14-10.また文字列更新時にレコードデイトもその時の日時で更新されるようにしてあげる
            memoData.recordDate = Date()
           // 14-5.
            realm.add(memoData)
        }
        // 14-12.最後にsaveDataメソッドが実行された際にメモデータプロパティの値をログに出力して確認できるようにしておく
        print("text: \(memoData.text), recordDate: \(memoData.recordDate)")
    }
}

// 14-6.次にデータを保存するタイミングについてだが、今回はUITextViewの文字列が変更される度にデータが上書きされるようにしたい
// UITableViewの文字列が変更された際に処理をしたい場合はUITextViewデリゲートというプロトコルを使用する
// このプロトコルの中にあるtextViewDidChangeというメソッドが文字列変更時に実行されるものとなる
extension MemoDetailViewController: UITextViewDelegate {
    // この中でデータ保存のメソッドを実行してあげる
    func textViewDidChange(_ textView: UITextView) {
        // 14-11.このメソッドの書き換えによってエラーが出てしまったのでこれも解消する
        // これはsaveDataメソッドに新しく追加されたデータが足りていないという意味のエラーなので引数を渡すように修正してあげればOK
        // 入力後の文字列はこのようにTextViewのTextプロパティから取得が可能なのでそれをsaveDataメソッドに渡せばOK
        let updatedText = textView.text ?? ""
        saveData(with: updatedText)
    }
}
