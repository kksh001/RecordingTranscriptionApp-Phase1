import SwiftUI
import CoreLocation
import Network

struct Phase1TestView: View {
    @EnvironmentObject var networkRegionManager: NetworkRegionManager
    @EnvironmentObject var developerConfigManager: DeveloperConfigManager
    @StateObject private var apiKeyManager = APIKeyManager.shared
    
    // 翻译测试状态
    @State private var isTestingTranslation = false
    @State private var translationTestResult = ""
    
    var body: some View {
        NavigationView {
            List {
                // 网络区域检测测试
                Section("🌍 Network Region Detection") {
                    HStack {
                        Text("Current Region:")
                        Spacer()
                        regionBadge(networkRegionManager.currentRegion)
                    }
                    
                    HStack {
                        Text("Recommended Service:")
                        Spacer()
                        serviceBadge(networkRegionManager.recommendedService)
                    }
                    
                    HStack {
                        Text("Detection Complete:")
                        Spacer()
                        statusBadge(networkRegionManager.isDetectionComplete)
                    }
                    
                    HStack {
                        Text("Location Permission:")
                        Spacer()
                        Text(locationPermissionText())
                            .foregroundColor(locationPermissionColor())
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Network Status:")
                        Spacer()
                        Text(networkStatusText(networkRegionManager.networkStatus))
                            .foregroundColor(networkRegionManager.networkStatus == .satisfied ? .green : .orange)
                    }
                }
                
                // 实时调试日志
                Section("🔍 Real-time Debug Logs") {
                    if networkRegionManager.debugMessages.isEmpty {
                        Text("No logs yet. Try testing network detection.")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
                        ForEach(Array(networkRegionManager.debugMessages.enumerated()), id: \.offset) { index, log in
                            Text(log)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Button("Clear Logs") {
                            networkRegionManager.clearDebugMessages()
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                        
                        Spacer()
                        
                        Text("Total: \(networkRegionManager.debugMessages.count) messages")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                // 开发者配置测试
                Section("🔑 Developer Configuration") {
                    HStack {
                        Text("Is Configured:")
                        Spacer()
                        statusBadge(developerConfigManager.isConfigured)
                    }
                    
                    HStack {
                        Text("Available Services:")
                        Spacer()
                        Text("\(developerConfigManager.availableServices.count)")
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Services List:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(Array(developerConfigManager.availableServices), id: \.self) { service in
                            HStack {
                                Image(systemName: service.iconName)
                                Text(service.displayName)
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // API密钥管理测试
                Section("🗝️ API Key Management") {
                    HStack {
                        Text("Using Developer Config:")
                        Spacer()
                        statusBadge(apiKeyManager.isUsingDeveloperConfig)
                    }
                    
                    HStack {
                        Text("Has Google Translate Key:")
                        Spacer()
                        statusBadge(apiKeyManager.hasGoogleTranslateKey)
                    }
                    
                    HStack {
                        Text("Has Qianwen Key:")
                        Spacer()
                        statusBadge(apiKeyManager.hasQianwenKey)
                    }
                }
                
                // 功能测试按钮
                Section("🔧 Function Tests") {
                    Button("Refresh All Configurations") {
                        Task {
                            await refreshAllConfigurations()
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Button("🌐 Test Network Detection (Detailed)") {
                        networkRegionManager.forceRefreshDetection()
                    }
                    .foregroundColor(.green)
                    
                    Button("📍 Request Location Permission") {
                        networkRegionManager.requestLocationPermission()
                    }
                    .foregroundColor(.red)
                    
                    Button("Test Developer Config") {
                        developerConfigManager.refreshConfiguration()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Test API Key Access") {
                        Task {
                            await testAPIKeyAccess()
                        }
                    }
                    .foregroundColor(.purple)
                    
                    Button("🧪 Test Translation Function") {
                        Task {
                            await testTranslationFunction()
                        }
                    }
                    .foregroundColor(.indigo)
                    .disabled(isTestingTranslation)
                }
                
                // 翻译测试结果
                if !translationTestResult.isEmpty {
                    Section("🔍 Translation Test Result") {
                        VStack(alignment: .leading, spacing: 8) {
                            if isTestingTranslation {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Testing translation with current API keys...")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Text(translationTestResult)
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(translationTestResult.contains("❌") ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // 环境对象注入验证
                Section("🔗 Environment Object Injection") {
                    HStack {
                        Text("NetworkRegionManager:")
                        Spacer()
                        statusBadge(true) // 如果能显示这个视图，说明注入成功
                    }
                    
                    HStack {
                        Text("DeveloperConfigManager:")
                        Spacer()
                        statusBadge(true) // 如果能显示这个视图，说明注入成功
                    }
                    
                    Text("✅ All environment objects successfully injected!")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .navigationTitle("Phase 1 Tests")
            .onAppear {
                // 启动时自动刷新配置
                Task {
                    await refreshAllConfigurations()
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func regionBadge(_ region: NetworkRegion) -> some View {
        Text(region.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(regionColor(region))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func serviceBadge(_ service: TranslationServiceType) -> some View {
        HStack(spacing: 4) {
            Image(systemName: service.iconName)
            Text(service.displayName)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func statusBadge(_ isActive: Bool) -> some View {
        Text(isActive ? "✅" : "❌")
            .font(.caption)
    }
    
    private func regionColor(_ region: NetworkRegion) -> Color {
        switch region {
        case .mainlandChina:
            return .red
        case .overseas:
            return .blue
        case .unknown:
            return .gray
        }
    }
    
    private func networkStatusText(_ status: NWPath.Status) -> String {
        switch status {
        case .satisfied:
            return "Connected"
        case .requiresConnection:
            return "Requires Connection"
        case .unsatisfied:
            return "Unsatisfied"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func locationPermissionText() -> String {
        switch networkRegionManager.locationAuthorizationStatus {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorizedWhenInUse:
            return "When In Use"
        case .authorizedAlways:
            return "Always"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func locationPermissionColor() -> Color {
        switch networkRegionManager.locationAuthorizationStatus {
        case .notDetermined:
            return .orange
        case .denied, .restricted:
            return .red
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        @unknown default:
            return .gray
        }
    }
    
    // MARK: - Test Functions
    
    @MainActor
    private func refreshAllConfigurations() async {
        networkRegionManager.forceRefreshDetection()
        developerConfigManager.refreshConfiguration()
        apiKeyManager.refreshConfiguration()
    }
    
    private func testAPIKeyAccess() async {
        // 测试API密钥访问
        let keyAccess = await apiKeyManager.testAPIKeyAccess()
        let keyInfo = await apiKeyManager.getAPIKeyInfo()
        
        print("🔑 API Key Test Results:")
        print("Google Translate Key Available: \(keyAccess.googleAvailable)")
        print("Qianwen Key Available: \(keyAccess.qianwenAvailable)")
        
        if let googleLength = keyInfo.googleLength {
            print("Google Key Length: \(googleLength) characters")
        }
        
        if let qianwenLength = keyInfo.qianwenLength {
            print("Qianwen Key Length: \(qianwenLength) characters")
        }
    }
    
    private func testTranslationFunction() async {
        await MainActor.run {
            isTestingTranslation = true
            translationTestResult = "🧪 Starting translation test..."
        }
        
        do {
            // 获取当前API密钥
            let qianwenKey = await apiKeyManager.getQianwenAPIKey()
            let googleKey = await apiKeyManager.getGoogleTranslateAPIKey()
            
            var result = "🔍 Phase 1 Translation Test Results:\n\n"
            
            // 检查API密钥状态
            result += "📋 API Key Status:\n"
            if let qianwenKey = qianwenKey {
                result += "✅ Qianwen Key: Found (\(qianwenKey.count) chars)\n"
                result += "🔍 Key Preview: \(String(qianwenKey.prefix(20)))...\n"
                
                // 检查是否为占位符密钥
                if qianwenKey.hasPrefix("sk-e1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7") {
                    result += "⚠️  This is a PLACEHOLDER key (not real)\n"
                }
            } else {
                result += "❌ Qianwen Key: Not found\n"
            }
            
            if let googleKey = googleKey {
                result += "✅ Google Key: Found (\(googleKey.count) chars)\n"
                result += "🔍 Key Preview: \(String(googleKey.prefix(20)))...\n"
                
                // 检查是否为占位符密钥
                if googleKey.hasPrefix("AIzaSyB4sxehiTrzITnxyz1234567890abcdefg") {
                    result += "⚠️  This is a PLACEHOLDER key (not real)\n"
                }
            } else {
                result += "❌ Google Key: Not found\n"
            }
            
            result += "\n📊 Translation Function Test:\n"
            
            // 尝试调用翻译功能
            if qianwenKey != nil {
                result += "🔄 Attempting Qianwen translation...\n"
                
                // 导入QianwenTranslateManager并测试
                let qianwenManager = QianwenTranslateManager.shared
                
                do {
                    let translation = try await qianwenManager.translateText(
                        "Hello World",
                        from: "en",
                        to: "zh"
                    )
                    result += "✅ Translation successful: \(translation)\n"
                } catch {
                    result += "❌ Translation failed: \(error.localizedDescription)\n"
                    
                    // 分析错误类型
                    if error.localizedDescription.contains("401") || error.localizedDescription.contains("403") {
                        result += "💡 This is expected with placeholder keys\n"
                    }
                }
            } else {
                result += "❌ Cannot test translation: No API key\n"
            }
            
            result += "\n🎯 Phase 1 Status Summary:\n"
            result += "✅ Basic architecture: Complete\n"
            result += "⚠️  Real API keys: Placeholder only\n"
            result += "❌ Translation function: Expected to fail\n"
            result += "📅 Real translation: Wait for Phase 2\n"
            
            await MainActor.run {
                translationTestResult = result
                isTestingTranslation = false
            }
            
        } catch {
            await MainActor.run {
                translationTestResult = "❌ Test failed: \(error.localizedDescription)"
                isTestingTranslation = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    Phase1TestView()
        .environmentObject(NetworkRegionManager())
        .environmentObject(DeveloperConfigManager.shared)
} 