import ArgumentParser

struct Options: ParsableArguments {
    @Option(default: "/notebooks/avolodin/data/horse2zebra/", help: ArgumentHelp("Path to the dataset folder", valueName: "dataset"))
    var datasetPath: String
    
    @Option(default: 3, help: ArgumentHelp("GPU Index", valueName: "gpu-index"))
    var gpuIndex: UInt
    
    @Option(default: 200, help: ArgumentHelp("Number of epochs", valueName: "epochs"))
    var epochs: Int
    
    @Option(default: "/tmp/tensorboardx", help: ArgumentHelp("TensorBoard logdir path", valueName: "tensorboard-logdir"))
    var tensorboardLogdir: String
}
