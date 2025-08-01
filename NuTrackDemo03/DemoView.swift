import SwiftUI

struct ContentView: View {
    // 營養素數據
    @State private var carbsProgress: Double = 0.4
    @State private var proteinProgress: Double = 0.3
    @State private var fatProgress: Double = 0.15
    let kcalLeft = 600
    let kcalEaten = 1200
    let kcalBurned = 400

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    // 返回動作
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text("Calories")
                    .font(.headline)
                Spacer()
                Image(systemName: "person.crop.circle")
                    .font(.title2)
            }
            .padding()

            Spacer()

            // 卡路里圓環
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)

                // 複合進度環 - 用三個半圓疊加
                Circle()
                    .trim(from: 0, to: CGFloat(carbsProgress))
                    .stroke(Color.green, lineWidth: 20)
                    .rotationEffect(.degrees(-90))
                Circle()
                    .trim(from: 0, to: CGFloat(proteinProgress))
                    .stroke(Color.blue, lineWidth: 20)
                    .rotationEffect(.degrees(-90 + carbsProgress * 360))
                Circle()
                    .trim(from: 0, to: CGFloat(fatProgress))
                    .stroke(Color.red, lineWidth: 20)
                    .rotationEffect(.degrees(-90 + (carbsProgress + proteinProgress) * 360))

                VStack {
                    Text("\(kcalLeft) KCAL LEFT")
                        .font(.title3)
                        .bold()
                    Text("of 2200 kcal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 200, height: 200)

            // SEE STATS 按鈕
            Button(action: {
                // 按鈕動作
            }) {
                Text("SEE STATS")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(Color.blue)
                    .cornerRadius(22)
            }
            .padding(.top)

            // 營養素進度條
            VStack(alignment: .leading, spacing: 15) {
                NutritionProgressView(title: "Carbs", value: carbsProgress, color: .green, amount: 75)
                NutritionProgressView(title: "Protein", value: proteinProgress, color: .blue, amount: 60)
                NutritionProgressView(title: "Fat", value: fatProgress, color: .red, amount: 35)
            }
            .padding(.horizontal)

            Spacer()

            // 今日數據 文字展示
            HStack(spacing: 40) {
                VStack {
                    Text("EATEN")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(kcalEaten)")
                        .bold()
                }
                VStack {
                    Text("BURNED")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(kcalBurned)")
                        .bold()
                }
                VStack {
                    Text("NET")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(kcalEaten - kcalBurned)")
                        .bold()
                }
            }
            .padding(.bottom, 40)

            // Footer 導航列
            HStack {
                Spacer()
                FooterButton(systemIconName: "house.fill", title: "Home")
                Spacer()
                FooterButton(systemIconName: "list.bullet", title: "Diary")
                Spacer()
                Button(action: {
                    // 新增紀錄
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                Spacer()
                FooterButton(systemIconName: "chart.bar", title: "Trends")
                Spacer()
                FooterButton(systemIconName: "gear", title: "Settings")
                Spacer()
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct NutritionProgressView: View {
    let title: String
    let value: Double // 0~1
    let color: Color
    let amount: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.3))
                Capsule()
                    .frame(width: CGFloat(value) * 250, height: 10)
                    .foregroundColor(color)
            }
            Text("\(amount) g")
                .font(.footnote)
                .foregroundColor(color)
                .padding(.top, 2)
        }
    }
}

struct FooterButton: View {
    let systemIconName: String
    let title: String

    var body: some View {
        VStack {
            Image(systemName: systemIconName)
                .font(.title2)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.blue)
    }
}

#Preview {
    ContentView()
}
