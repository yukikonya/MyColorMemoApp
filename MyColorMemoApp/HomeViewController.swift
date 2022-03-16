//
//  HomeViewController.swift
//  MyColorMemoApp
//
//  Created by Yuki Konya on 2022/02/18.
//

import Foundation
import UIKit // UIに関するクラスが格納されたモジュール
import RealmSwift

// HomeViewControllerにUIViewControllerを「クラス継承」する
class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var memoDataList: [MemoDataModel] = []
    // themeColorを保存するメソッドを追加
    let themeColorTypeKey = "themeColorTypeKey"
    
    override func viewDidLoad() {
        // このクラスの画面が表示される際に呼び出されるメソッド
        // 画面の表示・非表示に応じて実行されるメソッドを「ライフサイクルメソッド」と呼ぶ
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        // 10-6.最後にヘッダーにボタンを追加するためにsetNavigationBarをviewDidLoad内で実行してあげる
        // これでこの画面を表示した際にボタンの追加を行うようにできた→実際にアプリの挙動を確認
        // ヘッダーにメモ追加ボタンが表示された。ボタンタップ時の画面遷移についても問題なし。
        // ここで実際に画面をタップすると画面に配置されているUITextViewのキーボードが立ち上がる
        // このままだとキーボードを閉じることができないのでキーボードを閉じる処理も追加する
        setNavigationBarButton()
        setLeftNavigationBarButton()
        // 次にホーム画面を表示した際にUserDefaultsからthemeColorを取得して反映する処理も書いていく
        // まずUserDefaultsからInt型のデータを取得する際にはstandardプロパティに含まれるintegerメソッドを使用する
        // このforKeyの引数に対して先ほどデータ保存する際に使用したキー文字列を渡すことで保存した値を取得することが可能
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: themeColorTypeKey)
        // 次に取得したInt型の値をMyColorTypeのイニシャライザーに定義されているrawValueという引数に渡すことでMyColorTypeに変換することができる
        // この時、このrawValueという引数を持つイニシャライザーはMyColorTypeのOptionl型を返すものなのでdefault値を指定しておく
        // これでThemeColorの保存と反映の定義ができたのでアプリの挙動を確認
        let themeColorType = MyColorType(rawValue: themeColorTypeInt) ?? .default
        setThemeColor(type: themeColorType)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // このようにviewWillAppearメソッド内でsetMemodDataを実行することで画面が表示されるたびに毎回データの取得を行うようにできる
        setMemoData()
        // これでデータの更新は画面が表示される度に行われるが、データを画面に反映させるためにこのタイミングでUITableViewの更新処理も実行してあげる必要がある
        // UITableViewの表示更新をするにはこのようにreloadDataメソッドを実行してあげればOK
        // ではこれでもう一度アプリを実行して挙動の確認をする
        tableView.reloadData()
    }
    
    func setMemoData() {
        // まずはRealmをインスタンス化して
        let realm = try! Realm()
        // インスタンス化したRealmからメモデータモデルのクラスから全件取得し
        let result = realm.objects(MemoDataModel.self)
        // 取得結果を配列としてメモデータリストに代入するという処理に書き換えた
        // この状態で一度アプリを実行してみる
        memoDataList = Array(result)
//        for i in 1...5 {
//            // 13-5.そうするとモデルからストラクトからクラスに書き換わったことによってイニシャライザがなくなったためにエラーが発生したことわかる
//            // let memoDataModel = MemoDataModel(text: "このメモは\(i)番目のメモです。", recordDate: Date())
//            // これを解消していく。
//            // これでエラーが解消されたのでもう一度アプリを実行してみる
//            // 正常にモデルの書き換えが完了しアプリの実行ができた。今回のようにモデルなどを書き換えた場合意図しない箇所でエラーが発生するケースもあるので注意
//            let memoDataModel = MemoDataModel()
//            memoDataModel.text = "このメモは\(i)番目のメモです。"
//            memoDataModel.recordDate = Date()
//            memoDataList.append(memoDataModel)
//        }
    }
    // 10-1.UINavigationControllerにボタンを追加する処理
    // 10-5.そしてボタンタップ時に実行されるtapAddButtonメソッドについて
    // ここではメインストーリーボードのメモ詳細画面であるMemoDetailViewControllerを取得して画面遷移させる処理を定義している
    // これでメモの新規登録ボタンを押した際にメモ詳細画面へ遷移させるようにした
    @objc func tapAddButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memoDetailViewController = storyboard.instantiateViewController(identifier: "MemoDetailViewController") as!
            MemoDetailViewController
        navigationController?.pushViewController(memoDetailViewController, animated: true)
    }
    
    func setNavigationBarButton() {
        // 10-2.はじめにセレクタークラスをインスタンス化している
        // これはヘッダーに表示するボタンをタップした際に処理を指定するためのクラス
        // このセレクタークラスは定義方法は独特で#の後に小文字でセレクターと書き、その後に括弧内に実行対象となるメソッド名を指定する
        // つまりここではボタンをタップした際に、タップアドボタンメソッドが実行される
        // 注意点、セレクタークラスに指定するメソッドには必ず＠objcというキーワードをつけることがルールとなっている
        // これはセレクタークラスに指定したクラスが、Objective-Cという古いiOSの言語から実行されることが原因
        let buttonActionSelector: Selector = #selector(tapAddButton)
        // 10-3.ここではUIBarButtonItemクラスをインスタンス化している。これはUINavigationControllerに配置するButtonクラスのこと
        // 引数に指定されているbarButtonSystemItemはボタンの見た目を指定するもので今回はメモを追加するボタンなので.addという種別を選択している
        // これに続いてaction引数には先ほど定義したButtonActionSelectorを渡してあげればオッケー
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: buttonActionSelector)
        // 10-4.最後にrightBarButtonをnavigationItemのrightBarButtonItemというプロパティに代入してあげればヘッダー部分にボタンが表示される
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // ヘッダーの左側にボタンを配置するメソッドを作成
    func setLeftNavigationBarButton() {
        // 今回はコードでボタンを追加するためSelectorクラスを使ってボタンをタップした時の処理を定義できるように準備しておく
        let buttonActionSelector: Selector = #selector(didTapColorSettingButton)
        // 次にボタンを作成してNavigationItemにボタンを配置していく
        // まずは先ほどXcodeに追加したIcon画像をUIイメージクラスとしてインスタンス化して、
        let leftButtonImage = UIImage(named: "colorSettingIcon")
        // 次にNavigationItemを追加するためにUIBarButtonItemクラスとしてインスタンス化する
        // この時ボタンの画像を指定するためにleftButtonImageも引数として渡してあげる
        // またボタンタップ時の挙動を指定するためにbuttonActionSelectorも引数に渡す
        let leftButton = UIBarButtonItem(image: leftButtonImage, style: .plain, target: self, action: buttonActionSelector)
        // 最後にnavigationItemにこのボタンのインスタンスを代入すればOK
        // そしてこのメソッドをviewDidLoad内で実行するようにしておく
        navigationItem.leftBarButtonItem = leftButton
    }
    
    // ボタンをタップした際にテーマカラーの選択肢を表示させる
    // アクションシートを実装
    @objc func didTapColorSettingButton() {
        // UIAlertActionというAlertをタップした際の挙動を定義するクラスを追加している
        // この時Alertのタイトルと表示スタイル、タップされた際の処理内容などを引数として渡すルールになっている
        // そして引数のhandlerについて、これはクロージャというSwiftの構文だがこのように中括弧内にタップされた時の処理を書いてあげればOK
        let defaultAction = UIAlertAction(title: "デフォルト", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .default)
//          print("デフォルトがタップされました！")
        })
        let orangeAction = UIAlertAction(title: "オレンジ", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .orange)
//          print("オレンジがタップされました！")
        })
        let redAction = UIAlertAction(title: "レッド", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .red)
//          print("レッドがタップされました！")
        })
        let blueAction = UIAlertAction(title: "ブルー", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .blue)
        })
        let pinkAction = UIAlertAction(title: "ピンク", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .pink)
        })
        let greenAction = UIAlertAction(title: "グリーン", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .green)
        })
        let purpleAction = UIAlertAction(title: "パープル", style: .default, handler: { _ -> Void in
            self.setThemeColor(type: .purple)
        })
        // 次にキャンセルアクションについて、同様にUIAlertActionと使い、styleの引数をcancelとし、handlerにはnilを渡している
        // styleにcancelを指定した場合にはタップされた際にアラートが閉じるようになっている
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        // 次にUIAlertControllerについて、これはAlert自体のControllerをインスタンス化していて引数にはタイトルとメッセージ、アラートの種類を渡している
        // また今回はアクションシート形式のアラートを表示するためアクションシートという種別を指定している
        let alert = UIAlertController(title: "テーマカラーを選択してください", message: "", preferredStyle: .actionSheet)
        
        // 次にUIAlertControllerのaddActionメソッドの引数に対してこれまでに定義したUIAlertActionのインスタンスを渡している
        // これをしてあげないとAlertに設定が反映されない
        alert.addAction(defaultAction)
        alert.addAction(orangeAction)
        alert.addAction(redAction)
        alert.addAction(cancelAction)
        alert.addAction(blueAction)
        alert.addAction(pinkAction)
        alert.addAction(greenAction)
        alert.addAction(purpleAction)
        
        // 最後にここまでに作成したAlertを実際に表示するためにpresentメソッドにUIAlertControllerを引数として渡している
        // これでAlertの準備が整ったので実際にアプリを実行して挙動を確認
        present(alert, animated: true)
    }
    
    func setThemeColor(type: MyColorType) {
        // ヘッダーの色によってはボタンの色と被って見にくい状態になってしまう場合もあるのでヘッダーボタンの色も変更する
        // まずは指定された配色がdefaultかどうか判別するisDefaultタイプという定数を宣言する
        let isDefault = type == .default
        // 次に指定された色がdefaultだった場合にはUIColorクラスの黒を、default以外だった場合には白を代入するtintColor定数も定義する
        let tintColor: UIColor = isDefault ? .black : .white
        // 最後にUINavigationControllerのnavigationBarプロパティに含まれているtintColorに対して値を代入することでボタンの色を変更している
        navigationController?.navigationBar.tintColor = tintColor
        // UINavigationBarの配色を変更する際にはこのUINavigationControllerクラスのnavigationBarプロパティに含まれるbarTintColorに色の値を代入すればOK
        // この時、事前に定義しておいたMyColorTypeのColorプロパティを代入することで任意の色を指定できるようにした
        // これをアクションシートがタップされたときに適用するようにしてみる
        // navigationController?.navigationBar.barTintColor = type.color
        // ※iOS13以降ではUINavigationBarの背景色を変更する際にUINavigationBarAppearanceというUIクラスを使用する様になったため変更
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = type.color
        // Dictionary型→[Key: Value]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        // テーマカラーを変更した後にメモ詳細画面を開くとタイトルの色が黒のまま。これもヘッダーボタンと同じ色に変更されるようにしてあげる
        // ヘッダーのタイトルテキストを変更する場合はUINavigationControllerのnavigationBarプロパティのtitleTextAttributesに値を代入する。
        // この時に代入する値はNSAttributedString.KeyとAny型の値となる。このように特定のプロパティやメソッドの定義内容を確認する場合にはoptボタンを押しながら対象のコードをクリックすると確認ができる。
        // そしてこの時、titleTextAttributesに代入しているのはNSAttributedString.KeyのforegroundColorとtintColor
        // ここで定義されているように[]の中に:を挟んで値を定義する構文のことをDictionary型とよび、左がkeyで右がvalue
        // Dictionary型→[Key: Value]
        // foregroundColor→ヘッダーのタイトルの色を指定する、Value→tintColor→ヘッダータイトルの色を指定していることになる
        // navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
        // ThemeColorが選択された際にデータ保存メソッドを呼ぶ
        saveThemeColor(type: type)
    }
    
    // UserDefaultsへデータを保存する際にはstandardというプロパティに含まれるsetValueというメソッドを使用する
    // この時、ひとつ目の引数には保存する値を渡し、二つ目の引数にはデータにアクセスするためのキーとなる文字列を渡す
    // この二つ目の引数であるキーの文字列はアプリ内で一意である必要があるので注意
    // 今回はあらかじめ定義してあるthemeColorTypeKeyという文字列をキー名にしている
    // また保存をするのはMyColorTypeをInt型として表現した値なのでこのようにrawValueという値を引数に指定すればInt型の値を渡すことができる
    // あとはThemeColorが選択された際にこのデータ保存メソッドを呼ぶようにすればOK
    func saveThemeColor(type: MyColorType) {
            UserDefaults.standard.setValue(type.rawValue, forKey: themeColorTypeKey)
    }
}

extension HomeViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return memoDataList.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            // indexPath.row→UItableViewに表示されるCellの(0から始まる)通り番号が順番に渡される
            let memoDataModel: MemoDataModel = memoDataList[indexPath.row]
            cell.textLabel?.text = memoDataModel.text
            cell.detailTextLabel?.text = "\(memoDataModel.recordDate)"
            return cell
        }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboad = UIStoryboard(name: "Main", bundle: nil)
        let memoDetailViewController = storyboad.instantiateViewController(identifier: "MemoDetailViewController") as!
            MemoDetailViewController
        let memoData = memoDataList[indexPath.row]
        memoDetailViewController.configure(memo: memoData)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(memoDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // まずはスワイプされたindexPathを使ってmemoDataListから削除対象のメモデータを取得
        let targetMemo = memoDataList[indexPath.row]
        // Realmデータの削除はdeleteメソッドに対して削除したいオブジェクトを引数として渡せばOK
        let realm = try! Realm()
        try! realm.write {
            realm.delete(targetMemo)
        }
        // HomeViewControllerクラス内のmemoDataListプロパティ内のデータも削除する
        memoDataList.remove(at: indexPath.row)
        // UITableViewの表示内容が残ってしまうのでセルの削除処理を行う
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
}
