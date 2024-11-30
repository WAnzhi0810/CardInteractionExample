//
//  ContentView.swift
//  CardInteractionExample
//
//  Created by Zeno on 2024/11/29.
//

import SwiftUI

/// ContentView 是整个应用的主视图结构
/// 它展示了一个可以水平滚动的3D卡片堆叠效果
struct ContentView: View {
    // MARK: - 1. 基础数据定义
    /// 卡片的颜色数组：使用蓝色系的渐变色
    /// hue: 色调(0-1)，0.6表示蓝色
    /// saturation: 饱和度(0-1)，越大颜色越深
    /// brightness: 亮度(0-1)，越大越亮
    private let cardColors: [Color] = [
        Color(hue: 0.6, saturation: 0.6, brightness: 0.9), // 最浅的蓝色
        Color(hue: 0.6, saturation: 0.7, brightness: 0.8),
        Color(hue: 0.6, saturation: 0.8, brightness: 0.7),
        Color(hue: 0.6, saturation: 0.9, brightness: 0.6),
        Color(hue: 0.6, saturation: 1.0, brightness: 0.5)  // 最深的蓝色
    ]
    
    /// 定义要显示的卡片总数
    private let totalCards = 30
    
    // MARK: - 2. 屏幕尺寸计算
    /// 获取当前设备的屏幕宽度
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    /// 获取当前设备的屏幕高度
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // MARK: - 3. 布局间距计算
    /// 计算卡片堆叠的左侧间距
    /// 基于iPhone 16 Pro的屏幕宽度(430)进行等比例缩放
    private var cardStackLeftPadding: CGFloat {
        return -240 * (screenWidth / 430)
    }
    
    /// 计算卡片堆叠的底部间距
    /// 基于iPhone 16 Pro的屏幕高度(932)进行等比例缩放
    private var cardStackBottomPadding: CGFloat {
        return -360 * (screenHeight / 932)
    }
    
    /// 计算卡片堆叠的右侧间距
    private var cardStackRightPadding: CGFloat {
        return screenWidth - (180 * (screenWidth / 430))
    }
    
    // MARK: - 4. 主视图布局
    var body: some View {
        ZStack {
            // 设置黑色背景，并忽略安全区域
            Color.black.ignoresSafeArea()
            
            // 创建水平滚动视图
            ScrollView(.horizontal) {
                cardStackView
            }
            .scrollClipDisabled() // 允许内容超出滚动区域显示
        }
    }
    
    // MARK: - 5. 卡片堆叠视图
    /// 创建整体卡片堆叠效果的视图
    private var cardStackView: some View {
        HStack(spacing: -260) { // 负间距使卡片重叠
            ForEach((0..<totalCards), id: \.self) { index in
                cardView(for: index)
            }
        }
        .padding(.leading, cardStackLeftPadding)
        .padding(.bottom, cardStackBottomPadding)
        .padding(.trailing, cardStackRightPadding)
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - 6. 单个卡片视图
    /// 创建单张卡片的视图
    /// - Parameter index: 卡片的索引号
    private func cardView(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.ultraThinMaterial) // 使用半透明材质效果
            .background {
                // 设置卡片背景色，循环使用颜色数组
                cardColors[index % cardColors.count]
                    .opacity(0.3) // 设置透明度
                    .blur(radius: 3) // 添加模糊效果
            }
            .frame(width: 300, height: 500)
            // 添加滚动过渡动画效果
            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .rotation3DEffect( // 3D旋转效果
                        .degrees(calculateCardRotation(phase: phase, index: index)),
                        axis: (x: 0.5, y: 1.8, z: 1.2),
                        anchor: .topTrailing,
                        anchorZ: 0,
                        perspective: 0.5
                    )
                    .scaleEffect(calculateCardScale(phase: phase), anchor: .bottomTrailing)
            }
            .zIndex(-Double(index)) // 设置卡片层级，索引越大越靠后
    }
    
    // MARK: - 7. 动画计算方法
    /// 计算卡片在不同滚动阶段的缩放比例
    private func calculateCardScale(phase: ScrollTransitionPhase) -> CGFloat {
        switch phase {
        case .bottomTrailing: return 1.0  // 卡片在最小状态时的缩放比例
        case .topLeading: return 1.9      // 卡片在最大状态时的缩放比例
        case .identity: return 1.4        // 卡片在正常状态时的缩放比例
        }
    }
    
    /// 计算卡片的旋转角度
    /// - Parameters:
    ///   - phase: 滚动阶段
    ///   - index: 卡片索引
    private func calculateCardRotation(phase: ScrollTransitionPhase, index: Int) -> Double {
        let maxRotation = -10.0  // 定义最大旋转角度
        
        // 根据卡片索引计算初始角度（-45度到-55度之间）
        let initialAngle = (Double(index) / Double(totalCards - 1)) * maxRotation - 45
        
        // 根据滚动阶段调整角度
        return initialAngle * (1 + phase.value)
    }
}

// MARK: - 8. 预览
#Preview {
    ContentView()
}
