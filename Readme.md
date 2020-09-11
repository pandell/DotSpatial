# What is DotSpatial?

DotSpatial is a geographic information system library written for .NET Framework (please see [Pandell variant](#pandell-variant) for .NET Core 3.1+).
It allows developers to incorporate spatial data, analysis and mapping functionality into their applications or to contribute GIS extensions to the community.

DotSpatial provides a map control for .NET and several GIS capabilities including:

* Display a map in a .NET Windows Forms.
* Open shapefiles, grids, rasters and images.
* Render symbology and labels.
* Reproject on the fly.
* Manipulate and display attribute data.
* Scientific analysis.
* Read GPS data.

### Questions & Documentation

Please use the [discussion list](https://dotspatial.codeplex.com/discussions) to post any discussions related to the development or use of DotSpatial libraries. This is a great place to discuss potential features and to ask questions about how to use the libraries.

Documentation and code samples:
* [documentation page](https://dotspatial.codeplex.com/documentation) 
* [chm file with API documentation](https://github.com/DotSpatial/DotSpatial/tree/master/Source/Documentation/DotSpatial.chm)
* [examples folder](https://github.com/DotSpatial/DotSpatial/tree/master/Source/Examples).

Still have questions? Maybe someone already [asked them](https://github.com/DotSpatial/DotSpatial/issues?utf8=✓&q=label%3Aquestion).

### Contribute

See [Contributing](.github/CONTRIBUTING.md) for information about how to contribute!

### Links

* Continious integration build [![Build status](https://ci.appveyor.com/api/projects/status/7tof6s7m07qdad3b/branch/master?svg=true)](https://ci.appveyor.com/project/mogikanin/dotspatial/branch/master)
* [Changelog](https://github.com/DotSpatial/DotSpatial/blob/master/Changelog.md)
* [Latest available build from master branch](https://ci.appveyor.com/api/projects/mogikanin/dotspatial/artifacts/Source/bin/Release.zip?branch=master)
* [Continious Integration builds Nuget feed](https://ci.appveyor.com/nuget/dotspatial)

### License

It's MIT. The original DotSpatial (dotspatial.codeplex.com) was released under the LGPL, the new version hosted on GitHub is released under the MIT license.

### NuGet packages
You can download the latest stable release via NuGet.

Package | 
--------|
[	DotSpatial.Serialization](https://www.nuget.org/packages/DotSpatial.Serialization) |
[	DotSpatial.Data](https://www.nuget.org/packages/DotSpatial.Data) |
[	DotSpatial.Data.Forms](https://www.nuget.org/packages/DotSpatial.Data.Forms) |
[	DotSpatial.Topology](https://www.nuget.org/packages/DotSpatial.Topology) |
[	DotSpatial.Projections](https://www.nuget.org/packages/DotSpatial.Projections) |
[	DotSpatial.Projections.Forms](https://www.nuget.org/packages/DotSpatial.Projections.Forms) |
[	DotSpatial.Analysis](https://www.nuget.org/packages/DotSpatial.Analysis) |
[	DotSpatial.Compatibility](https://www.nuget.org/packages/DotSpatial.Compatibility) |
[	DotSpatial.Controls](https://www.nuget.org/packages/DotSpatial.Controls) |
[	DotSpatial.Extensions](https://www.nuget.org/packages/DotSpatial.Extensions) |
[	DotSpatial.Modeling.Forms](https://www.nuget.org/packages/DotSpatial.Modeling.Forms) |
[	DotSpatial.Symbology](https://www.nuget.org/packages/DotSpatial.Symbology) |
[	DotSpatial.Symbology.Forms](https://www.nuget.org/packages/DotSpatial.Symbology.Forms) |
[	DotSpatial.Mono](https://www.nuget.org/packages/DotSpatial.Mono) |
[	DotSpatial.Positioning](https://www.nuget.org/packages/DotSpatial.Positioning) |
[	DotSpatial.Positioning.Forms](https://www.nuget.org/packages/DotSpatial.Positioning.Forms) |
[	DotSpatial.Positioning.Design](https://www.nuget.org/packages/DotSpatial.Positioning.Design) |

---

# Pandell variant

- Builds using .NET Core SDK (3.1.301 or newer)
- Removes dependency on GeoAPI
- Updates NetTopologySuite dependency to version 2.0.0

### How to develop

```powershell
# verify .NET SDK
dotnet --info
# => .NET Core SDK (reflecting any global.json):
# => Version: 3.1.402
# => ...

# download repository
cd [development-directory-root]
git clone https://github.com/pandell/DotSpatial.git
cd DotSpatial

# build ("Debug" configuration)
dotnet build

# test ("Debug" configuration)
dotnet test -m:1 # "-m:1" tests assemblies sequentially, not in parallel
dotnet test -m:1 -v normal --no-build # prints tests being run, faster startup, sequential

# package ("Release" configuration)
# note: only specify "IsExperimental=True" property for pre-release builds
# this will create packages with version "X.Y.Z-preview.Q"
git clean -dfx
dotnet pack --configuration Release --output build -p:BUILD_NUMBER=X.Y.Z.Q -p:IsExperimental=True

# push all projects to Pandell's MyGet server (requires "package" step above to be run first)
# note: in addition to ".nupkg", the command below will automatically
# detect ".snupkg" symbol package and push both ".nupkg" and ".snupkg"
# to the specified NuGet server; for more information see
# https://docs.microsoft.com/en-us/nuget/create-packages/symbol-packages-snupkg
# dotnet nuget push build/*.nupkg --api-key SECRET --source https://api.nuget.org/v3/index.json
# (note about package pattern: .NET Core SDK 3.1.402 fails with "File does not exist"
# when using "universal directory separator" '/', so we have to use Windows-only '\' for now)
dotnet nuget push build\*.nupkg --api-key SECRET --source https://www.myget.org/F/pandell-nuget/auth/SECRET/api/v3/index.json
```
