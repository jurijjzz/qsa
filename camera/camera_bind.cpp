#include <iostream>
#include <string>

#include <pybind11/pybind11.h>

#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"

namespace py = pybind11;

Spinnaker::SystemPtr syscam;
Spinnaker::CameraPtr cam;

void start_camera() {
	syscam = Spinnaker::System::GetInstance();
	auto cam_list = syscam->GetCameras();

	if (cam_list.GetSize() == 0) {
		std::cerr << "No cameras found." << std::endl;
		return;
	}

	cam = cam_list.GetByIndex(0);
	// Settings
	// cam->ExposureMode.SetValue(Spinnaker::ExposureMode_Timed);
	// cam->ExposureTime.SetValue(200000000000, true);

	try {
		cam->Init();
		auto& nodeMap = cam->GetNodeMap();

		Spinnaker::GenApi::CEnumerationPtr ptrAcquisitionMode = nodeMap.GetNode("AcquisitionMode");
		
		if (!Spinnaker::GenApi::IsReadable(ptrAcquisitionMode) || !Spinnaker::GenApi::IsWritable(ptrAcquisitionMode))
		{
			std::cerr << "Unable to set acquisition mode to continuous (enum retrieval). Aborting..." << std::endl;
			return ;
		}

		// Retrieve entry node from enumeration node
		auto ptrAcquisitionModeContinuous = ptrAcquisitionMode->GetEntryByName("Continuous");
		if (!Spinnaker::GenApi::IsReadable(ptrAcquisitionModeContinuous))
		{
			std::cerr << "Unable to get or set acquisition mode to continuous (entry retrieval). Aborting..." << std::endl;
			return ;
		}

		// Retrieve integer value from entry node
		const int64_t acquisitionModeContinuous = ptrAcquisitionModeContinuous->GetValue();

		// Set integer value from entry node as new value of enumeration node
		ptrAcquisitionMode->SetIntValue(acquisitionModeContinuous);

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

	} catch (Spinnaker::Exception& e) {
		std::cerr << "Error: " << e.what() << std::endl;
		cam->DeInit();
		cam_list.Clear();
		syscam->ReleaseInstance();
		return;
	}

	cam_list.Clear();
}

void stop_camera() {
	cam->DeInit();
	syscam->ReleaseInstance();
}

void take_picture(std::string filename, std::size_t n=10) {
	try {
		// Start taking picture
		cam->BeginAcquisition();
        std::cout << "Taking images..." << std::endl;

        // Capturing n images
        for (size_t i = 0; i < n; i++) {
            Spinnaker::ImagePtr pImage = cam->GetNextImage();
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
            name << "grid2/image_" << index++ << ".png";
			pImage->Save(name.str().c_str());
		}

		cam->EndAcquisition();
	}
	catch (Spinnaker::Exception& e) {
		std::cerr << "Error: " << e.what() << std::endl;
		cam->DeInit();
		syscam->ReleaseInstance();
		return ;
	}
}

PYBIND11_MODULE(camera, handle) {
	handle.def("start", &start_camera);
	handle.def("stop", &stop_camera);
	handle.def("take_picture", &take_picture);
}
