import SwiftUI
import Combine

@MainActor
class TabBarViewModel: ObservableObject {
    @Published var selected: TabBarType = .goldenHours
}

enum TabBarType: Int, CaseIterable, Identifiable {
    case goldenHours, morning, yinYang, stat
    
    var id: Int {
        self.rawValue
    }

    var title: String {
        switch self {
        case .goldenHours:
            "Golden Hours"
        case .morning:
            "Lion's Morning"
        case .yinYang:
            "Yin Yang"
        case .stat:
            "Statistics"
        }
    }

    var iconName: String {
        switch self {
        case .goldenHours:
            "tab1"
        case .morning:
            "tab2"
        case .yinYang:
            "tab3"
        case .stat:
            "tab4"
        }
    }
}
    

struct TabBarView: View {
    @StateObject private var viewModel = TabBarViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                getTabContent(for: viewModel.selected)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer(minLength: 0)
                
                UIKitTabBar(selected: $viewModel.selected)
                    .frame(height: UIScreen.isIphoneSEClassic ? 100.fitH : 100.fitH)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    @ViewBuilder
    func getTabContent(for tab: TabBarType) -> some View {
        switch tab {
        case .goldenHours:
            GoldenHours()
        case .morning:
            MorningView()
        case .yinYang:
            YinYang()
        case .stat:
            StatView()
        }
    }
}

struct UIKitTabBar: UIViewRepresentable {
    @Binding var selected: TabBarType
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        for tab in TabBarType.allCases {
            let button = TabBarButton(tab: tab, isSelected: selected == tab) { selectedTab in
                selected = selectedTab
            }
            
            stackView.addArrangedSubview(button)
            
            context.coordinator.buttons[tab.rawValue] = button
        }
        
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        
        context.coordinator.updateAllButtons(for: selected)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateAllButtons(for: selected)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var buttons: [Int: TabBarButton] = [:]
        
        func updateAllButtons(for selected: TabBarType) {
            for tab in TabBarType.allCases {
                if let button = buttons[tab.rawValue] {
                    button.updateSelection(isSelected: selected == tab)
                }
            }
        }
    }
}

class TabBarButton: UIView {
    let tab: TabBarType
    var isSelected: Bool
    let onTap: (TabBarType) -> Void
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let label = UILabel()
    private let button = UIButton(type: .system)
    
    init(tab: TabBarType, isSelected: Bool, onTap: @escaping (TabBarType) -> Void) {
        self.tab = tab
        self.isSelected = isSelected
        self.onTap = onTap
        super.init(frame: .zero)
        
        setupUI()
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .fill
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        stackView.addArrangedSubview(imageView)
        
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = tab.title
        label.textAlignment = .center
        label.numberOfLines = 1
        stackView.addArrangedSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.onTap(self.tab)
        }, for: .touchUpInside)
    }
    
    func updateSelection(isSelected: Bool) {
        self.isSelected = isSelected
        updateIcon()
    }
    
    private func updateIcon() {
        let suffix = isSelected ? "-s" : "-d"
        let imageName = "\(tab.iconName)\(suffix)"
        imageView.image = UIImage(named: imageName)
    }
}

struct Mock: View {
    var body: some View {
        VStack {
            Spacer()
        }
    }
}
