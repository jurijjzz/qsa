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
set(Spinnaker_INCLUDE_DIR"C:/Program Files/Teledyne/Spinnaker/include")
link_directories("C:/Program Files/Teledyne/Spinnaker/lib64/vs2015")
```

## Setup Visual Studio:

### Ensure Visual Studio is Installed:
   - **MSVC Compiler:** Make sure Visual Studio includes the MSVC compiler.
   - **Configure Environment:** Adjust the environment settings to target the correct version of the Windows SDK and platform toolset, if necessary.

## Start up the Project:

### 1. Create a Python Virtual Environment:
   - **Command:** In the root of the directory, create a Python virtual environment:
     ```bash
     python -m venv venv
     ```


### 2. Activate the Virtual Environment:
   - **Windows:**
     ```bash
     .\venv\Scripts\activate
     ```
   - **Mac or Linux:**
     ```bash
     source venv/bin/activate
     ```

### 3. Install requirements
      ```bash
      pip.exe install -r requirements.txt
      ```

### 4. Install pybind11:
   - **Install Command:** With the virtual environment activated, install pybind11 using pip:
     ```bash
     pip install pybind11
     ```

## Open the Project:

- **Visual Studio:** Open the solution or project folder in Visual Studio.

## Build the Project:

### 1. Compile the Project:
   - **Build Solution:** Navigate to `Build > Build Solution` or press `Ctrl+Shift+B` to compile the project.

### 2. Organize Output Files:
   - Navigate to `qsa/camera/out/build/x64-debug`.
   - Move everything from the `x64-debug` folder to the `build` folder.
   - Delete the `x64-debug` folder, ensuring only `qsa/camera/out/build` remains.

## Run the Project:

### 1. Start the Application:
   - **Start Without Debugging:** After a successful build, start the project by selecting `Debug > Start Without Debugging` or press `Ctrl+F5` to run the application.
   - **Camera Solution Only:** You can now run only the camera solution.
   - **Full Software Suite:** If you want to run all software which includes camera, laser, and dmd-c, open `main.py` in `qsa` and press run!



### Additional Tips:
- Make sure to review the Spinnaker SDK documentation for any specific setup or configuration details related to the FLIR Grasshopper 3 camera.
- It's often helpful to verify the camera's connection and functionality using any provided diagnostic tools or sample applications from FLIR before integrating it into your project.

This updated documentation now includes important details about ensuring that the Spinnaker SDK is installed in the correct location, and how to adjust the paths in `CMakeLists.txt` if necessary. This will be helpful for developers needing to customize their environment setup.
