<img src="https://raw.githubusercontent.com/Yoonit-Labs/ios-yoonit-camera/master/logo_cyberlabs.png" width="300">

# ios-yoonit-camera

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Yoonit-Labs/ios-yoonit-camera?color=lightgrey&label=version&style=for-the-badge) ![GitHub](https://img.shields.io/github/license/Yoonit-Labs/ios-yoonit-camera?color=lightgrey&style=for-the-badge)

A iOS plugin to provide:
* Camera preview (Front & Back)
* Yoonit Facefy integration:
  * Android: [android-yoonit-facefy](https://github.com/Yoonit-Labs/android-yoonit-facefy)
  * iOS: [ios-yoonit-facefy](https://github.com/Yoonit-Labs/ios-yoonit-facefy)
* [PyTorch](https://pytorch.org/mobile/home/) integration (Soon)
* Computer vision pipeline (Soon)
* Face detection, capture and image crop
* Understanding of the human face
* Frame capture
* Capture timed images
* QR Code scanning

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
  * [Camera Preview](#camera-preview)
  * [Start capturing face images](#start-capturing-face-images)
  * [Start scanning QR Codes](#start-scanning-qr-codes)
* [API](#api)
  * [Methods](#methods)
  * [Events](#events)
    * [Face Analysis](#face-analysis)
    * [Head Movements](#head-movements)
  * [KeyError](#keyerror)
  * [Message](#message)
* [To contribute and make it better](#to-contribute-and-make-it-better)

## Installation

Add the following line to your `Podfile` file:

```  
pod 'YoonitCamera'
```

And run in the root of your project:

```
pod install
```  

## Usage  

All the functionalities that the `ios-yoonit-camera` provides is accessed through the `CameraView`, that includes the camera preview. See an example how we use in our [**Demo**](https://github.com/Yoonit-Labs/ios-yoonit-camera/tree/master/Example/YoonitCameraDemo).

<img src="https://raw.githubusercontent.com/Yoonit-Labs/ios-yoonit-camera/master/tutorial.gif" width="500" />

Below we have the basic usage code, for more details, see the [**API**](#api) section.

### Camera Preview

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
self.cameraView.startCaptureType("face")
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
    
    func onFaceDetected(
        x: Int, 
        y: Int, 
        width: Int, 
        height: Int, 
        leftEyeOpenProbability: NSNumber?, 
        rightEyeOpenProbability: NSNumber?, 
        smilingProbability: NSNumber?, 
        headEulerAngleX: NSNumber?, 
        headEulerAngleY: NSNumber?, 
        headEulerAngleZ: NSNumber?
    ) {
        // YOUR CODE
    }
    ...
}
```

### Start scanning QR Codes

With camera preview, we can start scanning QR codes:

```swift
self.cameraView.startCaptureType("qrcode")
```

Set camera event listener to get the result:

```swift
class YourViewController: UIViewController, CameraEventListenerDelegate {
    ...
    self.cameraView.cameraEventListener = self
    ...
    func onQRCodeScanned(content: String) {
        // YOUR CODE
    }
}
```

## API

### Methods   

| Function                        | Parameters                                                                    | Valid values                                                                      | Return Type | Description
| -                               | -                                                                             | -                                                                                 | -           | -  
| startPreview              | -                                                                             | -                                                                                 | void        | Start camera preview if has permission.
| startCaptureType          | `captureType: String`                                                         | <ul><li>`"none"`</li><li>`"face"`</li><li>`"qrcode"`</li><li>`"frame"`</li></ul> | void        | Set capture type none, face, QR Code or frame.
| stopCapture               | -                                                                             | -                                                                                 | void        | Stop any type of capture.
| destroy | - | - | void | Destroy camera preview.
| toggleCameraLens          | -                                                                             | -                                                                                 | void        | Toggle camera lens facing front/back.
| setCameraLens             | `cameraLens: String`        | <ul><li>`"front"`</li><li>`"back"`</li></ul>                                      | void         | Set camera to use "front" or "back" lens. Default value is "front".
| getCameraLens             | -                                                                             | -                                                                                 | String         | Return "front" or "back". 
| setNumberOfImages         | `numberOfImages: Int`                                                         | Any positive `Int` value                                                          | void        | Default value is 0. For value 0 is saved infinity images. When saved images reached the "number os images", the `onEndCapture` is triggered.
| setTimeBetweenImages      | `timeBetweenImages: Int64`                                                     | Any positive number that represent time in milli seconds                          | void        | Set saving face/frame images time interval in milli seconds.
| setOutputImageWidth       | `width: Int`                                                                  | Any positive `number` value that represents in pixels                             | void        | Set face image width to be created in pixels.
| setOutputImageHeight      | `height: Int`                                                                 | Any positive `number` value that represents in pixels                             | void        | Set face image height to be created in pixels.
| setSaveImageCaptured      | `enable: Bool`                                                     | `true` or `false`                                                                 | void        | Set to enable/disable save image when capturing face and frame.
| setDetectionBox | `enable: Bool` | `true` or `false` | void | Set to enable/disable detection box when face/qrcode detected. The detection box is the the face/qrcode bounding box normalized to UI.
| setDetectionBoxColor | `alpha: Float, red: Float, green: Float, blue: Float`   | Value between `0` and `1` | void | Set detection box ARGB color. Default value is `(0.4, 1.0, 1.0, 1.0)`.
| setDetectionMinSize  | `minimumSize: Float` | Value between `0` and `1`. Represents the percentage. | void | Set face/qrcode minimum size to detect in percentage related with the camera preview.
| setDetectionMaxSize | `maximumSize: Float` | Value between `0` and `1`. Represents the percentage. | void | Set face/qrcode maximum size to detect in percentage related with the camera preview.
| setFaceContours              | `enable: Bool`                                  | `true` or `false`                                                               | void        | Set to enable/disable face contours when face detected. 
| setFaceContoursColor | `alpha: Float, red: Float, green: Float, blue: Float`   | Value between `0` and `1` | void        | Set face contours ARGB color. Default value is `(0.4, 1.0, 1.0, 1.0)`.
| setFacePaddingPercent | `facePaddingPercent: Float` | Any positive `Float` value. | void | Set face image and bounding box padding in percent.  
| setROI             | `enable: Bool`               | `true` or `false`                                                              | void        | Enable/disable the region of interest capture.
| setROITopOffset        | `topOffset: Float`       | Value between `0` and `1`. Represents the percentage. | void | Camera preview top distance in percentage. 
| setROIRightOffset     | `rightOffset: Float`   | Value between `0` and `1`. Represents the percentage. | void | Camera preview right distance in percentage.
| setROIBottomOffset | `bottomOffset: Float` | Value between `0` and `1`. Represents the percentage. | void | Camera preview bottom distance in percentage.
| setROILeftOffset       | `leftOffset: Float`     | Value between `0` and `1`. Represents the percentage. | void | Camera preview left distance in percentage.
| setROIAreaOffset | `enable: Bool` | `true` or `false` | void | Set to enable/disable region of interest offset visibility.
| setROIAreaOffsetColor | `alpha: Float, red: Float, green: Float, blue: Float` | Value between `0` and `1` | void | Set face region of interest area offset color. Default value is `(0.4, 1.0, 1.0, 1.0)`.
| setTorch | `enable: Bool` | `true` or `false` | void | Set to enable/disable the device torch. Available only to camera lens `"back"`.

### Events

| Event                     | Parameters                                                | Description
| -                         | -                                                         | -
| onImageCaptured | `type: String, count: Int, total: Int, imagePath: String` | Must have started capture type of face/frame (see `startCaptureType`). Emitted when the face image file is created: <ul><li>type: '"face"' or '"frame"'</li><li>count: current index</li><li>total: total to create</li><li>imagePath: the image path</li><ul>  
| onFaceDetected | `x: Int, y: Int, width: Int, height: Int, leftEyeOpenProbability: NSNumber?, rightEyeOpenProbability: NSNumber?, smilingProbability: NSNumber?, headEulerAngleX: NSNumber?, headEulerAngleY: NSNumber?, headEulerAngleZ: NSNumber?` | Must have started capture type of face. Emit the [face analysis](#face-analysis)
| onFaceUndetected | -                                                         | Must have started capture type of face. Emitted after `onFaceDetected`, when there is no more face detecting.
| onEndCapture | -                                                         | Must have started capture type of face/frame. Emitted when the number of image files created is equal of the number of images set (see the method `setNumberOfImages`).   
| onQRCodeScanned | `content: String`                                         | Must have started capture type of qrcode (see `startCaptureType`). Emitted when the camera scan a QR Code.   
| onError | `error: String`                                           | Emit message error.
| onMessage | `message: String`                                         | Emit message.
| onPermissionDenied | -                                                         | Emit when try to `startPreview` but there is not camera permission.

#### Face Analysis

The face analysis is the response send by the `onFaceDetected`. Here we specify all the parameters.

| Attribute               | Type     | Description |
| -                       | -        | -           |
| x                       | `Int`    | The `x` position of the face in the screen. |
| y                       | `Int`    | The `y` position of the face in the screen. |
| width                   | `Int`    | The `width` position of the face in the screen. |
| height                  | `Int`    | The `height` position of the face in the screen. |
| leftEyeOpenProbability  | `NSNumber?` | The left eye open probability. |
| rightEyeOpenProbability | `NSNumber?` | The right eye open probability. |
| smilingProbability      | `NSNumber?` | The smiling probability. |
| headEulerAngleX         | `NSNumber?`  | The angle in degrees that indicate the vertical head direction. See [Head Movements](#headmovements) |
| headEulerAngleY         | `NSNumber?`  | The angle in degrees that indicate the horizontal head direction. See [Head Movements](#headmovements) |
| headEulerAngleZ         | `NSNumber?`  | The angle in degrees that indicate the tilt head direction. See [Head Movements](#headmovements) |

#### Head Movements

Here we explaining the above gif and how reached the "results". Each "movement" (vertical, horizontal and tilt) is a state, based in the angle in degrees that indicate head direction;

| Head Direction | Attribute         |  _v_ < -36° | -36° < _v_ < -12° | -12° < _v_ < 12° | 12° < _v_ < 36° |  36° < _v_  |
| -              | -                 | -           | -                 | -                | -               | -           |
| Vertical       | `headEulerAngleX` | Super Down  | Down              | Frontal          | Up              | Super Up    |
| Horizontal     | `headEulerAngleY` | Super Right | Right             | Frontal          | Left            | Super Left  |
| Tilt           | `headEulerAngleZ` | Super Left  | Left              | Frontal          | Right           | Super Right |

### KeyError

Pre-define key error used by the `onError` event.

| KeyError                          | Description
| -                                 | -
| INVALID_CAPTURE_TYPE              | Tried to start a non-existent capture type.
| INVALID_CAMERA_LENS               | Tried to input invalid camera lens.
| INVALID_NUMBER_OF_IMAGES          | Tried to input invalid face/frame number of images to capture. 
| INVALID_TIME_BETWEEN_IMAGES       | Tried to input invalid face time interval to capture face.
| INVALID_OUTPUT_IMAGE_WIDTH        | Tried to input invalid image width.
| INVALID_OUTPUT_IMAGE_HEIGHT       | Tried to input invalid image height.
| INVALID_DETECTION_BOX_COLOR | Tried to input invalid detection box ARGB value color.
| INVALID_FACE_PADDING_PERCENT      | Tried to input invalid face padding percent.
| INVALID_MINIMUM_SIZE | Tried to input invalid minimum size. 
| INVALID_MAXIMUM_SIZE | Tried to input invalid maximum size.
| INVALID_ROI_TOP_OFFSET       | Tried to input invalid region of interest top offset.
| INVALID_ROI_RIGHT_OFFSET     | Tried to input invalid region of interest right offset.
| INVALID_ROI_BOTTOM_OFFSET    | Tried to input invalid region of interest bottom offset.
| INVALID_ROI_LEFT_OFFSET      | Tried to input invalid region of interest left offset.
| INVALID_ROI_COLOR               | Tried to input invalid region of interest area offset ARGB value color.
| INVALID_FACE_CONTOURS_COLOR          | Tried to input invalid face contour ARGB value color.

### Message

Pre-define key messages used by the `onMessage` event.

| Message                           | Description
| -                                 | -
| INVALID_MINIMUM_SIZE | Face/QRCode width percentage in relation of the screen width is less than the set (`setDetectionMinSize`).
| INVALID_MAXIMUM_SIZE | Face/QRCode width percentage in relation of the screen width is more than the set (`setMaximumSize`).
| INVALID_OUT_OF_ROI | Face bounding box is out of the set region of interest (`setROI`).

## To contribute and make it better

Clone the repo, change what you want and send PR.

For commit messages we use <a href="https://www.conventionalcommits.org/">Conventional Commits</a>.

Contributions are always welcome!

<a href="https://github.com/Yoonit-Labs/ios-yoonit-camera/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Yoonit-Labs/ios-yoonit-camera" />
</a>

---

Code with ❤ by the [**Cyberlabs AI**](https://cyberlabs.ai/) Front-End Team
