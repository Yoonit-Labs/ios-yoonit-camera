<img src="https://raw.githubusercontent.com/Yoonit-Labs/ios-yoonit-camera/master/logo_cyberlabs.png" width="300">

# ios-yoonit-camera

![Generic badge](https://img.shields.io/badge/version-v1.3.2-<COLOR>.svg) ![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)

A iOS plugin to provide:
- Camera preview (Front & Back)
- Face detection (With Min & Max size)
- Landmark detection (Soon)
- Face crop
- Face capture
- Frame capture
- Face ROI (Soon)
- QR Code scanning

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
    func onImageCaptured(type: String, count: Int, total: Int, imagePath: String) {
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
| **`startCaptureType`**          | `captureType: String`          | void        | <ul><li>`"none"`</li><li>`"face"`</li><li>`"barcode"`</li><li>`"frame"`</li></ul> | Set capture type none, face, barcode and frame.
| **`stopCapture`**              | -                             | void        | -                                                               | Stop any type of capture.
| **`toggleCameraLens`**         | -                             | void        | -                                                               | Set camera lens facing front or back.
| **`getCameraLens`**            | -                             | Int         | -                                                               | Return `Int` that represents lens face state: 0 for front 1 for back camera.  
| **`setFaceNumberOfImages`**    | `faceNumberOfImages: Int`     | void        | Any positive `Int` value                                        | Default value is 0. For value 0 is saved infinity images. When saved images reached the "face number os images", the `onEndCapture` is triggered.
| **`setFaceDetectionBox`**      | `faceDetectionBox: Bool`   | void        | `true` or `false`                                               | Set to show face detection box when face detected.   
| **`setFaceTimeBetweenImages`** | `faceTimeBetweenImages: Int64` | void        | Any positive number that represent time in milli seconds        | Set saving face images time interval in milli seconds.  
| **`setFacePaddingPercent`**    | `facePaddingPercent: Float`   | void        | Any positive `Float` value                                      | Set face image and bounding box padding in percent.  
| **`setFaceImageSize`**         | `width: Int, height: Int`     | void        | Any positive `Int` value                                        | Set face image size to be saved.
| **`setFaceCaptureMinSize`**     | `faceCaptureMinSize: Float`       | void        | Value between `0` and `1`. Represents the percentage.                             | void        | Set the minimum face capture based on the screen width limit.
| **`setFaceCaptureMaxSize`**     | `faceCaptureMaxSize: Float`       | void        | Value between `0` and `1`. Represents the percentage.                            | Set the maximum face capture based on the screen width limit.
| **`setFrameTimeBetweenImages`** | `frameTimeBetweenImages: Int64` | void        | Any positive number that represent time in milli seconds                          | Set saving frame images time interval in milli seconds.
| **`setFrameNumberOfImages`**    | `frameNumberOfImages: Int`     | void        | Any positive `Int` value                                                          | Default value is 0. For value 0 is saved infinity images. When saved images reached the "frame number os images", the `onEndCapture` is triggered.

### Events

| Event                    | Parameters                                  | Description
| -                        | -                                           | -
| **`onImageCaptured`** | `type: String, count: Int, total: Int, imagePath: String` | Must have started capture type of face/frame (see `startCaptureType`). Emitted when the image file is created: <ul><li>type: 'frame' | 'face'<li/><li>count: current index</li><li>total: total to create</li><li>imagePath: the image path</li><ul>
| **`onFaceDetected`**     | `x: Int, y: Int, width: Int, height: Int`   | Must have started capture type of face. Emit the detected face bounding box.
| **`onFaceUndetected`**   | -                                           | Must have started capture type of face. Emitted after `onFaceDetected`, when there is no more face detecting.
| **`onEndCapture`**        | -                                           | Must have started capture type of face or frame. Emitted when the number of face or frame image files created is equal of the number of images set (see the method `setFaceNumberOfImages` for face and `setFrameNumberOfImages` for frame).   
| **`onBarcodeScanned`**   | `content: String`                           | Must have started capture type of barcode (see `startCaptureType`). Emitted when the camera scan a QR Code.   
| **`onError`**             | `error: String`                             | Emit message error. Argument may be a string or an pre-defined[**KeyError**](###KeyError).
| **`onMessage`**           | `message: String`                           | Emit message. Argument may be a string or an pre-defined[**Message**](###Message).   
| **`onPermissionDenied`** | -                                           | Emit when try to `startPreview` but there is not camera permission.

### KeyError

Pre-define key error constants used by the `onError`event.

| KeyError                          | Description
| -                                 | -
| NOT_STARTED_PREVIEW               | Tried to start a process that depends on to start the camera preview.
| INVALID_CAPTURE_TYPE              | Tried to start a non-existent capture type.
| INVALID_FACE_NUMBER_OF_IMAGES     | Tried to input invalid face number of images to capture. 
| INVALID_FACE_TIME_BETWEEN_IMAGES  | Tried to input invalid face time interval to capture face.
| INVALID_FACE_PADDING_PERCENT      | Tried to input invalid face padding percent.
| INVALID_FACE_IMAGE_SIZE           | Tried to input invalid image width or height.
| INVALID_FACE_CAPTURE_MIN_SIZE     | Tried to input invalid face capture minimum size. 
| INVALID_FACE_CAPTURE_MAX_SIZE     | Tried to input invalid face capture maximum size.
| INVALID_FRAME_NUMBER_OF_IMAGES    | Tried to input invalid frame number of images to capture.
| INVALID_FRAME_TIME_BETWEEN_IMAGES | Tried to input invalid frame time interval to capture face.

### Message

Pre-define message constants used by the `onMessage`event.

| Message                | Description
| -                             | -
| INVALID_CAPTURE_FACE_MIN_SIZE | Face bounding box width percentage in relation of the screen width is less than the setted (`setFaceCaptureMinSize`).
| INVALID_CAPTURE_FACE_MAX_SIZE | Face bounding box width percentage in relation of the screen width is more than the setted (`setFaceCaptureMaxSize`).

## To contribute and make it better

Clone the repo, change what you want and send PR.

Contributions are always welcome!

---

Code with ❤ by the [**Cyberlabs AI**](https://cyberlabs.ai/) Front-End Team
