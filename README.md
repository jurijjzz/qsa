# Starting the Project Using Visual Studio

This project requires building in Visual Studio with the MSVC (Microsoft Visual C++) compiler. Ensure the following prerequisites are met before running the project:

- The full version of the Spinnaker SDK is installed.
- The FLIR Grasshopper 3 camera is connected.

## Installation Verification and Setup

Ensure that the Spinnaker SDK is installed in the following default directories:

- Include files should be in `C:/Program Files/Teledyne/Spinnaker/include`
- Libraries should be in `C:/Program Files/Teledyne/Spinnaker/lib64/vs2015`

If the Spinnaker SDK is installed in a different location, update the paths accordingly in the `CMakeLists.txt` file:

```cmake
include_directories("Your/Custom/Path/To/Spinnaker/include")
link_directories("Your/Custom/Path/To/Spinnaker/lib64/vs2015")
```

## Steps to Run

1. **Setup Visual Studio:**
   - Ensure Visual Studio is installed with the MSVC compiler.
   - Configure the environment to target the correct version of the Windows SDK and platform toolset if necessary.

2. **Open the Project:**
   - Open the solution file (`only_camera`) in Visual Studio.

3. **Build the Project:**
   - Select `Build > Build Solution` (or press `Ctrl+Shift+B`) to compile the project.

4. **Run the Project:**
   - After successful build, start the project by selecting `Debug > Start Without Debugging` (or press `Ctrl+F5`) to run the application.


### Additional Tips:
- Make sure to review the Spinnaker SDK documentation for any specific setup or configuration details related to the FLIR Grasshopper 3 camera.
- It's often helpful to verify the camera's connection and functionality using any provided diagnostic tools or sample applications from FLIR before integrating it into your project.

This updated documentation now includes important details about ensuring that the Spinnaker SDK is installed in the correct location, and how to adjust the paths in `CMakeLists.txt` if necessary. This will be helpful for developers needing to customize their environment setup.
