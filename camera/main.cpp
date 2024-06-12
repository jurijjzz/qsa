#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"

#include <iostream>
#include <ostream>
#include <vector>
#include <ranges>
#include <numeric>

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
    std::vector<Spinnaker::ImagePtr> images;

    try {
        // Initialize camera
        pCam->Init();
        Spinnaker::GenApi::INodeMap& nodeMap = pCam->GetNodeMap();
        Spinnaker::GenApi::CEnumerationPtr pixelFormat = nodeMap.GetNode("PixelFormat");
        if (Spinnaker::GenApi::IsAvailable(pixelFormat) && Spinnaker::GenApi::IsWritable(pixelFormat)) {
            Spinnaker::GenApi::CEnumEntryPtr mono16 = pixelFormat->GetEntryByName("Mono16");
            if (Spinnaker::GenApi::IsAvailable(mono16) && Spinnaker::GenApi::IsReadable(mono16)) {
                pixelFormat->SetIntValue(mono16->GetValue());
                std::cout << "Pixel format set to Mono16." << std::endl;
            }
            else {
                std::cerr << "Mono16 format not available." << std::endl;
                return -1;
            }
        }
        else {
            std::cerr << "Pixel format not writable." << std::endl;
            return -1;
        }

        // Start image acquisition
        pCam->BeginAcquisition();
        std::cout << "Taking images..." << std::endl;

        // Capture 10 images
        for (int i = 0; i < 10; i++) {
            Spinnaker::ImagePtr pImage = pCam->GetNextImage();
            if (pImage->IsIncomplete()) {
                std::cerr << "Image incomplete, skipping..." << std::endl;
            }
            else {
                images.push_back(pImage);
                std::cout << "Image " << i + 1 << " captured: "
                    << pImage->GetWidth() << " x " << pImage->GetHeight()
                    << " | Pixel Format: " << pImage->GetPixelFormatName() << std::endl;
            }
        }

        std::cout << (images[0].get() == images[1].get() ? "Same" : "Not") << std::endl;

        int index = 0;
        for (const auto& pImage : images) {
            auto name = std::ostringstream{};
            name << "grid1/image_" << index++ << ".png";
			pImage->Save(name.str().c_str());
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

    // Clean up
    camList.Clear();
    system->ReleaseInstance();

    return 0;
}
