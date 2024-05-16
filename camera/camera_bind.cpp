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

void take_picture(std::string filename) {
	try {
		// Start taking picture
		cam->BeginAcquisition();
		std::cout << "Taking image..." << std::endl;

		Spinnaker::ImagePtr pImage = cam->GetNextImage();

		if (pImage->IsIncomplete()) {
			std::cerr << "Image incomplete." << std::endl;
		}
		else {
			const size_t width = pImage->GetWidth();
			const size_t height = pImage->GetHeight();

			std::cout << "Image captured: " << width << " x " << height << std::
			pImage->Save(filename.c_str());
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
