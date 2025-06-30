import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage = "English"
    let languages = ["English", "Chinese"]
    
    var body: some View {
        Form {
            Section(header: Text("Language")) {
                Picker("App Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { lang in
                        Text(lang)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Phase 1 Testing (Developer Only)
            Section(header: Text("🧪 Development Testing")) {
                NavigationLink(destination: Phase1TestView()) {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Phase 1 Architecture Tests")
                                .font(.headline)
                            Text("Test basic infrastructure components")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Placeholder for other settings
            Section(header: Text("About")) {
                Text("Version 1.5.0 - Phase 1")
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 