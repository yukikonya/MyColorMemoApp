//
//  MyColorType.swift
//  MyColorMemoApp
//
//  Created by Yuki Konya on 2022/02/28.
//

import Foundation
import UIKit

// まずはMyColorTypeをユーザーデフォルトに追加するためにInt型として表現できるように書き換える
// ローバリューの型がInt型である列挙型MyColorType
enum MyColorType: Int {
    // テーマカラーを定義していく
    // defaultケースについてはSwiftの構文上defaultキーワードと重複してしまうのでシングルクォーテーションで囲む必要がある
    // Swiftであらかじめ使用されているキーワードのことを予約語と呼ぶ
    case `default` // #ffffff // 0
    case orange // #f8c165 // 1
    case red // #d24141 // 2
    case blue // #4187fa // 3
    case pink // #f064b9 // 4
    case green // #50aa41 // 5
    case purple // #965ad2 // 6
    
    // 16進数のカラーコードをrgbaに変換するサイトを調べる
    // MyColorのケースごとにUIColorを定義していく
    var color: UIColor {
        switch self {
        case .default: return .white
        // この時、rgbaメソッドはUIColorクラスをインスタンス化せずに使用しているがこれはrgbaメソッドを定義する際にstaticキーワードを付与しているためインスタンス化しなくても使用できる静的なメソッドとして定義しているため
        // このようにインスタンス化が不要な場合にはstaticを用いる
        case .orange: return UIColor.rgba(red: 248, green: 193, blue: 101, alpha: 1)
        case .red: return UIColor.rgba(red: 210, green: 65, blue: 65, alpha: 1)
        case .blue: return UIColor.rgba(red: 65, green: 135, blue: 250, alpha: 1)
        case .pink: return UIColor.rgba(red: 240, green: 100, blue: 185, alpha: 1)
        case .green: return UIColor.rgba(red: 80, green: 170, blue: 65, alpha: 1)
        case .purple: return UIColor.rgba(red: 150, green: 90, blue: 210, alpha: 1)
        }
    }
}

extension UIColor {
    // rgbaメソッドを定義
    static func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
}
