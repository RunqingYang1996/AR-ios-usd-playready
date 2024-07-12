import SwiftUI
import RealityKit
import Combine

struct USDView: UIViewRepresentable {
    var fileName: String
    @Binding var currentAnimation: String
    @State private var cancellables: Set<AnyCancellable> = []

    class Coordinator {
        var idleModel: Entity?
        var nodeheadModel: Entity?
        var talkModel: Entity?
        var anchor: AnchorEntity?
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Load the usdz file as an Entity from the app bundle
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "usdz") else {
            print("Failed to find USD file in the bundle")
            return arView
        }

        do {
            let characterAnimationSceneEntity = try Entity.load(contentsOf: fileURL)

            // Ensure the entity has the correct name
            context.coordinator.idleModel = characterAnimationSceneEntity.findEntity(named: "Armature_007")
            context.coordinator.nodeheadModel = characterAnimationSceneEntity.findEntity(named: "Armature_003")
            context.coordinator.talkModel = characterAnimationSceneEntity.findEntity(named: "Armature_001")

            // Create an anchor and store it in the coordinator
            context.coordinator.anchor = AnchorEntity(world: .zero)
            arView.scene.anchors.append(context.coordinator.anchor!)

        } catch {
            print("Failed to load USD file: \(error)")
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        guard let anchor = context.coordinator.anchor else { return }

        // Remove all children from the anchor
        anchor.children.removeAll()

        // Play the selected animation
        switch currentAnimation {
        case "idle":
            if let idleModel = context.coordinator.idleModel,
               let idleAnimationResource = idleModel.availableAnimations.first {
                anchor.addChild(idleModel)
                idleModel.setPosition([0, -0.8, 0], relativeTo: anchor) // Adjust the position
                idleModel.setOrientation(simd_quatf(angle: .pi / 2, axis: [-1, 0, 0]), relativeTo: anchor) // Adjust the orientation if needed
                idleModel.playAnimation(idleAnimationResource.repeat())
            }
        case "talk":
            if let talkModel = context.coordinator.talkModel,
               let talkAnimationResource = talkModel.availableAnimations.first {
                anchor.addChild(talkModel)
                talkModel.setPosition([0, -0.8, 0], relativeTo: anchor) // Adjust the position
                talkModel.setOrientation(simd_quatf(angle: .pi / 2, axis: [-1, 0, 0]), relativeTo: anchor) // Adjust the orientation if needed
                talkModel.playAnimation(talkAnimationResource.repeat())
            }
        case "nodehead":
            if let nodeheadModel = context.coordinator.nodeheadModel,
               let nodeheadAnimationResource = nodeheadModel.availableAnimations.first {
                anchor.addChild(nodeheadModel)
                nodeheadModel.setPosition([0, -0.8, 0], relativeTo: anchor) // Adjust the position
               nodeheadModel.setOrientation(simd_quatf(angle: .pi / 2, axis: [-1, 0, 0]), relativeTo: anchor) // Adjust the orientation if needed
                nodeheadModel.playAnimation(nodeheadAnimationResource.repeat())
            }
        default:
            break
        }
    }
}

struct ContentView: View {
    @State private var currentAnimation: String = ""

    var body: some View {
        VStack {
            USDView(fileName: "changeall6", currentAnimation: $currentAnimation)
                .edgesIgnoringSafeArea(.all)

            HStack {
                Button("idle") {
                    currentAnimation = "idle"
                }
                .padding()

                Button("talk") {
                    currentAnimation = "talk"
                }
                .padding()

                Button("Nodehead") {
                    currentAnimation = "nodehead"
                }
                .padding()
            }
        }
    }
}
