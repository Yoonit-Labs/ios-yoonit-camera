<img src="https://raw.githubusercontent.com/Yoonit-Labs/ios-yoonit-camera/master/logo_cyberlabs.png" width="300">

# ios-yoonit-camera

![Generic badge](https://img.shields.io/badge/version-v1.0.3-<COLOR>.svg) ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

Face image capture and QR Code scanning library.

## Install

Add the following line to your `Podfile` file:

```  
pod 'YoonitCamera'
```

And run in the root of your project:

```
pod install
```  

## Usage  
  All the functionalities that the `ios-yoonit-camera` provides is accessed through the `CameraView`, that includes the camera preview.  Below we have the basic usage code, for more details, see the [**Methods**](#methods).

### Camera Preview

1. Open `storyboard`;
2. Select one scene;
3. Navigate do `Identity Inspector` > `Custom Class`;
4. Select your `class`;
4. In the dropdown select `YoonitCamera`;
5. Link the custom view with the `YoonitCamera` inside your class with a var. In our case we are going to use like this:

```swift
@IBOutlet var cameraView: CameraView!
```

Do not forget request camera permission. Start camera preview:

```swift
self.cameraView.startPreview()
```

### Start capturing face images

With camera preview, we can start capture detected face and generate images:

```swift
self.cameraView.startCaptureType(captureType: "face")
```

Set camera event listener to get the result:

```swift
class YourViewController: UIViewController, CameraEventListenerDelegate {
    ...
    self.cameraView.cameraEventListener = self
    ...
    func onFaceImageCreated(count: Int, total: Int, imagePath: String) {
        // YOUR CODE
    }
}
```

### Start scanning QR Codes

With camera preview, we can start scanning QR codes:

```swift
this.cameraView.startCaptureType(captureType: "barcode")
```

Set camera event listener to get the result:

```swift
class YourViewController: UIViewController, CameraEventListenerDelegate {
    ...
    self.cameraView.cameraEventListener = self
    ...
    func onBarcodeScanned(content: String) {
        // YOUR CODE
    }
}
```

## API

### Methods   

| Function                       | Parameters                    | Return Type | Valid values                                                    | Description
| -                              | -                             | -           | -                                                               | -  
| **`startPreview`**             | -                             | void        | -                                                               | Start camera preview if has permission.
| **`startCaptureType`**         | `captureType: String`         | void        | <ul><li>`"none"`</li><li>`"face"`</li><li>`"barcode"`</li></ul> | Set capture type none, face or barcode.
| **`stopCapture`**              | -                             | void        | -                                                               | Stop any type of capture.
| **`toggleCameraLens`**         | -                             | void        | -                                                               | Set camera lens facing front or back.
| **`getCameraLens`**            | -                             | Int         | -                                                               | Return `Int` that represents lens face state: 0 for front 1 for back camera.  
| **`setFaceNumberOfImages`**    | `faceNumberOfImages: Int`     | void        | Any positive `Int` value                                        | Default value is 0. For value 0 is saved infinity images. When saved images reached the "face number os images", the `onEndCapture` is triggered.
| **`setFaceDetectionBox`**      | `faceDetectionBox: Bool`   | void        | `true` or `false`                                               | Set to show face detection box when face detected.   
| **`setFaceTimeBetweenImages`** | `faceTimeBetweenImages: Int64` | void        | Any positive number that represent time in milli seconds        | Set saving face images time interval in milli seconds.  
| **`setFacePaddingPercent`**    | `facePaddingPercent: Float`   | void        | Any positive `Float` value                                      | Set face image and bounding box padding in percent.  
| **`setFaceImageSize`**         | `width: Int, height: Int`     | void        | Any positive `Int` value                                        | Set face image size to be saved.

### Events

| Event                    | Parameters                                  | Description
| -                        | -                                           | -
| **`onFaceImageCreated`** | `count: Int, total: Int, imagePath: String` | Must have started capture type of face (see `startCaptureType`). Emitted when the face image file is created: <ul><li>count: current index</li><li>total: total to create</li><li>imagePath: the face image path</li><ul>  
| **`onFaceDetected`**     | `x: Int, y: Int, width: Int, height: Int`   | Must have started capture type of face. Emit the detected face bounding box.
| **`onFaceUndetected`**   | -                                           | Must have started capture type of face. Emitted after `onFaceDetected`, when there is no more face detecting.
| **`onEndCapture`**       | -                                           | Must have started capture type of face. Emitted when the number of face image files created is equal of the number of images set (see the method `setFaceNumberOfImages`).   
| **`onBarcodeScanned`**   | `content: String`                           | Must have started capture type of barcode (see `startCaptureType`). Emitted when the camera scan a QR Code.   
| **`onError`**            | `error: String`                             | Emit message error.  
| **`onMessage`**          | `message: String`                           | Emit message.   
| **`onPermissionDenied`** | -                                           | Emit when try to `startPreview` but there is not camera permission.


## To contribute and make it better

Clone the repo, change what you want and send PR.

Contributions are always welcome!

---

Code with ❤ by the [**Cyberlabs AI**](https://cyberlabs.ai/) Front-End Team
