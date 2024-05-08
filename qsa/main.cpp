#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>



int main() {
    // Initialize system
    Spinnaker::SystemPtr system = Spinnaker::System::GetInstance();
    Spinnaker::CameraList camList = system->GetCameras();

    if (camList.GetSize() == 0) {
        std::cerr << "No cameras found." << std::endl;
        system->ReleaseInstance();
        return -1;
    }

    Spinnaker::CameraPtr pCam = camList.GetByIndex(0);
    try {

        //Initialize camera
        pCam->Init();

        //Settings
        //pCam->ExposureAuto.SetValue(Spinnaker::ExposureAuto_Continuous);

        //Start taking picture
        pCam->BeginAcquisition();
        std::cout << "Taking image..." << std::endl;

        Spinnaker::ImagePtr pImage = pCam->GetNextImage();

        if (pImage->IsIncomplete()) {
            std::cerr << "Image incomplete." << std::endl;
        }
        else {
            const size_t width = pImage->GetWidth();
            const size_t height = pImage->GetHeight();

            std::cout << "Image captured: " << width << " x " << "height" << std::endl;
            pImage->Save("qsa.jpg");
        }

        pCam->EndAcquisition();
        pCam->DeInit();
    }
    catch (Spinnaker::Exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        pCam->DeInit();
        camList.Clear();
        system->ReleaseInstance();
        return -1;
    }

    //clean up

    camList.Clear();
    system->ReleaseInstance();
    return 0;
}
