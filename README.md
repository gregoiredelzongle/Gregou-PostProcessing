# Gre-Sketch
Edge detection filter and Werness dithering for Unity3D

![Alt text](https://cloud.githubusercontent.com/assets/9194561/16920072/7e658a46-4d0c-11e6-947b-455fb870b3f1.gif "Gre-Sketch")

Here's a collection of two image filters for Unity3D inspired par Lucas Pope work : https://forums.tigsource.com/?topic=40832.0

## GreEdgeDetectionEffect.cs
1. Disable static/dynamic batching (Edit/Project Settings/Player properties)
2. Disable normal smoothing on your meshes, you can vertex-paint some parts of the mesh in red to override edge detection
3. Drop this script into any camera
4. You can adjust values : depth treeshold stop drawing lines after a certain distance and color treeshold adjust line detection. The background and the line can be colored, alpha value works too.

## GreWernessDitherEffect.cs
1. Drop this script into any camera
2. Adjust values : Iterations should be kept at the lowest value for better performances, 
