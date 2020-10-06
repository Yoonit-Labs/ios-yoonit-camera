# YoonitCamera 
[![Generic badge](https://img.shields.io/badge/version-v1.0.0-<COLOR>.svg)](https://shields.io/)    
  
## Install
  
Add the following line to your Podfile file:
```  
pod 'YoonitCamera', :git => "git@github.com:Yoonit-Labs/ios-yoonit-camera.git", :tag => '1.0.0'
```
<br/>  
  
## Methods   
  
| Function | Parameters | Return Type | Valid values | Description |
|-|-|-|-|-|  
| **`startPreview`** | - | void | - | Start camera preview if has permission.
| **`startCaptureType`** | `captureType : String` | void | `none` default capture type. `face` for face recognition. `barcode` to read barcode content. | Set capture type none, face or barcode.
| **`stopCapture`** | - | void | - | Stop any type of capture.
| **`toggleCameraLens`** | - | void | - | Set camera lens facing front or back.
| **`getCameraLens`** | - | Int | - | Return `Int` that represents lens face state: 0 for front 1 for back camera.  
| **`setFaceNumberOfImages`** | `faceNumberOfImages: Int` | void | Any positive `Int` value | Default value is 0. For value 0 is saved infinity images. When saved images reached the "face number os images", the `onEndCapture` is triggered.
| **`setFaceDetectionBox`** |`faceDetectionBox: Boolean` | void | `True` or `False` | Set to show face detection box when face detected.   
| **`setFaceTimeBetweenImages`** | `faceTimeBetweenImages: Long` | void | Any positive number that represent time in milli seconds | Set saving face images time interval in milli seconds.  
| **`setFacePaddingPercent`** | `facePaddingPercent: Float` | void | Any positive `Float` value | Set face image and bounding box padding in percent.  
| **`setFaceImageSize`** | `faceImageSize: Int` | void | Any positive `Int` value | Set face image size to be saved.    
  
<br/>  
  
## Events

| Event | Parameters | Description |
|-|-|-|
| **`onFaceImageCreated`** | `count: Int, total: Int, imagePath: String` | Emit when the camera save an image face.  
| **`onFaceDetected`** | `faceDetected: Boolean` | Emit when a face is detected or hided.  
| **`onEndCapture`** | - | Emit when the number of images saved is equal of the number of images set.   
| **`onBarcodeScanned`** | `content: String` | Emit content when detect a barcode.   
| **`onError`** |`error: String` | Emit message error.  
| **`onMessage`** | `message: String` | Emit message.   
| **`onPermissionDenied`** | - | Emit when try to `startPreview` but there is not camera permission.
