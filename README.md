# Gregou Post Processing

Collection of various post processing effects for Unity (Tested with Unity 2020.3.8f1).
- Made for the [Post-Processing Stack V2](https://docs.unity3d.com/Packages/com.unity.postprocessing@3.1/manual/index.html).
- Compatible with the Built-in render pipeline.

## Installation
TODO

## Usage

1. [Post Processing Stack V2 Quick start](https://docs.unity3d.com/Packages/com.unity.postprocessing@3.1/manual/Quick-start.html)
2. You can add more effects under "Gregou" dropdown list (see below for effects description).

## Effects

### Gregou Dither
![Gregou_Dither](https://user-images.githubusercontent.com/9194561/118359398-81535f00-b583-11eb-90b8-c26d679da9d9.gif)

Dithering effect similar to [Lukas Pope's Obra Dinn image effect](https://forums.tigsource.com/?topic=40832.0).
|Parameters|Description|
|:---------|:---------:|
|Iterations|Error diffusion iterations (more means more diffused noise)|
|Sum Bias|Bias for the error diffusion (for more or less aligned patterns)|
|Dither Color|Apply optional color inside the dither pattern|
|Color Blend|Blend between source image and color for the dither pattern|
|Background Color|Apply optional color outside the dither pattern|
|Background Color Blend|Blend between source image and color outside the dither pattern|

### Gregou Edge Detection
![Gregou_EdgeDetection](https://user-images.githubusercontent.com/9194561/118359401-831d2280-b583-11eb-8a00-5847fc101010.gif)

Edge detection effect using Sobel.
|Parameters|Description|
|:---------|:---------:|
|Outline Color|Set color for the outline (black by default)|
|Background Color|Optional Background color (transparent by default)|
|Color Bias|Normal Bias for the sobel algorithm|
|Outline Width|Width in pixels|
