import TensorFlow
import Files
import Foundation

public class LabeledImages {
    struct Elements: TensorGroup {
        var image: Tensor<Float>
        var landmarks: Tensor<Float>
    }

    let dataset: Dataset<Elements>
    let count: Int

    public init(folder: Folder, imageSize: (Int, Int)) throws {
        let imageFiles = folder.files(extensions: ["jpg"])
        
        var landmarksArray: [Float] = []
        landmarksArray.reserveCapacity(68 * 2 * imageFiles.count)
        
        let tensorHandle = TensorHandle<Float>(shape: [imageFiles.count, imageSize.0, imageSize.1, 3]) { pointer in
            let decoder = JSONDecoder()
            let floatsPerImage = imageSize.0 * imageSize.1 * 3
            
            var elements = 0
            
            for imageFile in imageFiles {
                let imageTensor = Image(jpeg: imageFile.url).resized(to: imageSize).tensor / 127.5 - 1.0

                var imageScalars = imageTensor.scalars
                memcpy(pointer.advanced(by: floatsPerImage * elements), &imageScalars, floatsPerImage * 4)
                
                let landmarksPath = imageFile.url.path.replacingOccurrences(of: ".jpg", with: "_pts.landmarks")
                let landmarksData = try! Data(contentsOf: URL(fileURLWithPath: landmarksPath))
                let landmarks = try! decoder.decode(Tensorf.self, from: landmarksData)
                
                landmarksArray.append(contentsOf: landmarks.scalars)
                
                elements += 1
            }
        }

        let source = Tensorf(handle: tensorHandle)
        let landmarks = Tensorf(shape: [imageFiles.count, 68 * 2],
                                scalars: landmarksArray)
        self.dataset = .init(elements: Elements(image: source, landmarks: landmarks))
        
        self.count = imageFiles.count
    }
}
