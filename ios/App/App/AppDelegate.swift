import UIKit
import Capacitor

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

// MARK: - XM CRM: asosiy oyna (xmcrm.uz shu yerda ochiladi)

class XmViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(XmNativePlugin())
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        let bg = UIColor(red: 0xfa / 255.0, green: 0xfa / 255.0, blue: 0xf9 / 255.0, alpha: 1)
        view.backgroundColor = bg
        webView?.isOpaque = false
        webView?.backgroundColor = bg
        webView?.scrollView.backgroundColor = bg
    }
}

// MARK: - XM CRM: veb-sahifa uchun iOS imkoniyatlari (fayl ulashish, AirPrint)

@objc(XmNativePlugin)
public class XmNativePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "XmNativePlugin"
    public let jsName = "XmNative"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "shareFile", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "printPage", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "printHtml", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "info", returnType: CAPPluginReturnPromise)
    ]

    /// Excel/PDF faylni iOS "Ulashish" oynasida ochadi: Fayllarga saqlash, Telegram, AirDrop…
    @objc func shareFile(_ call: CAPPluginCall) {
        guard let b64 = call.getString("data"), let data = Data(base64Encoded: b64, options: .ignoreUnknownCharacters) else {
            call.reject("Fayl bo‘sh")
            return
        }
        var name = call.getString("name") ?? "fayl"
        name = name.replacingOccurrences(of: "/", with: "_")
        if name.isEmpty { name = "fayl" }
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("xm-share", isDirectory: true)
        let url = dir.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            call.reject("Faylni saqlab bo‘lmadi: \(error.localizedDescription)")
            return
        }
        DispatchQueue.main.async {
            guard let vc = self.bridge?.viewController else {
                call.reject("Oyna topilmadi")
                return
            }
            let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = vc.view
                pop.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 1, height: 1)
                pop.permittedArrowDirections = []
            }
            sheet.completionWithItemsHandler = { _, completed, _, _ in
                call.resolve(["completed": completed])
            }
            vc.present(sheet, animated: true)
        }
    }

    /// Joriy sahifani (chekni) AirPrint orqali chop etish
    @objc func printPage(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let web = self.bridge?.webView else {
                call.reject("Sahifa topilmadi")
                return
            }
            self.presentPrint(web.viewPrintFormatter(), call)
        }
    }

    /// Tayyor HTML ni (masalan Z-hisobot) AirPrint orqali chop etish
    @objc func printHtml(_ call: CAPPluginCall) {
        let html = call.getString("html") ?? ""
        DispatchQueue.main.async {
            self.presentPrint(UIMarkupTextPrintFormatter(markupText: html), call)
        }
    }

    @objc func info(_ call: CAPPluginCall) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        call.resolve(["version": version, "platform": "ios", "system": UIDevice.current.systemVersion])
    }

    private func presentPrint(_ formatter: UIPrintFormatter, _ call: CAPPluginCall) {
        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.jobName = "XM CRM"
        let controller = UIPrintInteractionController.shared
        controller.printInfo = info
        controller.printFormatter = formatter
        controller.present(animated: true) { _, completed, error in
            if let error = error {
                call.reject("Chop etib bo‘lmadi: \(error.localizedDescription)")
            } else {
                call.resolve(["printed": completed])
            }
        }
    }
}
