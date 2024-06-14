classdef alpV42 < handle
% Wrapper class for the ViALUX ALP-4 API.
%
% Matthijs Velsink, 2019-2020 
   
properties (Constant)
% All ALP-4 defined constants and structure templates
C = load('alpConstants.mat');
end

methods (Sealed)
    
function obj = alpV42()
    % Load ALP-4 API
    if ~libisloaded('ALP')
        loadlibrary('alpV42.dll', 'alpV42.h', 'alias', 'ALP');
    end
    fprintf('Loaded ALP-4 library.\n')
end

function checkError(obj, ret)
    % Checks return code and throws ALP-4 based errors.
    if ret ~= 0
        error('ALP-4 error: %s', obj.C.errorCode{ret - 1000})
    end
end

% All wrapper methods (see PDF for better descriptions!)
%------------------------------------------------------------------
function DeviceId = AlpDevAlloc(obj, DeviceNum, InitFlag)
    % This function allocates an ALP hardware system (board set) and 
    % returns an ALP handle so that it can be used by subsequent API 
    % functions. 
    % DeviceNum:    specifies the device to be used.
    % InitFlag:     specifies the type of initialization to perform on the
    %               selected system.
    [ret, DeviceId] = calllib('ALP', 'AlpDevAlloc', DeviceNum, InitFlag, 0);
    obj.checkError(ret);
end

function AlpDevControl(obj, DeviceId, ControlType, ControlValue)
    % This function is used to change the display properties of the ALP. 
    % The default values are assigned during device allocation by 
    % AlpDevAlloc.
    % DeviceId:     ALP device identifier.
    % ControlType:  control parameter that is to be modified.
    % ControlValue: value of the parameter.
    ret = calllib('ALP', 'AlpDevControl', DeviceId, ControlType, ControlValue);
    obj.checkError(ret);
end   

function UserVar = AlpDevInquire(obj, DeviceId, InquireType)
    % This function inquires a parameter setting of the specified 
    % ALP device.
    % DeviceId:     ALP device identifier for which the information is 
    %               requested.
    % InquireType:  specifies the ALP device parameter setting to inquire.               
    [ret, UserVar] = calllib('ALP', 'AlpDevInquire', DeviceId, InquireType, 0);
    obj.checkError(ret);
end

function AlpDevHalt(obj, DeviceId)
    % This function puts the ALP in an idle wait state. Current sequence 
    % display is canceled (ALP_PROJ_IDLE) and the loading of sequences is 
    % aborted (AlpSeqPut)
    % DeviceId:     ALP device identifier.
    ret = calllib('ALP', 'AlpDevHalt', DeviceId);
    obj.checkError(ret);
end              

function AlpDevFree(obj, DeviceId)
    % This function de-allocates a previously allocated ALP device. The 
    % memory reserved by calling AlpSeqAlloc is also released. The ALP has 
    % to be in idle wait state, see also AlpDevHalt.
    % DeviceId:     ALP identifier of the device to be freed.
    ret = calllib('ALP', 'AlpDevFree', DeviceId);
    obj.checkError(ret);
end

function SequenceId = AlpSeqAlloc(obj, DeviceId, BitPlanes, PicNum)
    % This function provides ALP memory for a sequence of pictures. All 
    % pictures of a sequence have the same bit depth. The function 
    % allocates memory from the ALP board RAM. The user has no direct 
    % read/write access. ALP functions provide data transfer using the 
    % sequence memory identifier (SequenceId) of type ALP_ID. Pictures can 
    % be loaded into the ALP RAM using the AlpSeqPut function. The 
    % availability of ALP memory can be tested using the AlpDevInquire 
    % function. When a sequence is no longer required, release it using 
    % AlpSeqFree.
    % DeviceId:     ALP device identifier.
    % BitPlanes:    bit depth of the patterns to be displayed; the 
    %               following values are supported: 1, 2, 3, 4, 5, 6, 7, 8.
    % PicNum        number of pictures belonging to the sequence; possible
    %               values depend upon the available memory 
    %               (ALP_AVAIL_MEMORY) and the bit depth (BitPlanes)
    [ret, SequenceId] = calllib('ALP', 'AlpSeqAlloc', DeviceId, BitPlanes, PicNum, 0);
    obj.checkError(ret);
end      

function AlpSeqControl(obj, DeviceId, SequenceId, ControlType, ControlValue)
    % This function is used to change the display properties of a sequence.
    % The default values are assigned during sequence allocation by 
    % AlpSeqAlloc. It is allowed to change settings of sequences that are 
    % currently in use. However the new settings become effective after 
    % restart using AlpProjStart or AlpProjStartCont.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier.
    % ControlType:  control parameter that is to be modified.
    % ControlValue: value of the parameter.
    ret = calllib('ALP', 'AlpSeqControl', DeviceId, SequenceId, ControlType, ControlValue);
    obj.checkError(ret);
end

function AlpSeqTiming(obj, DeviceId, SequenceId, IlluminateTime, PictureTime, ...
                           SynchDelay, SynchPulseWidth, TriggerInDelay)
    % This function controls the timing properties of the sequence display.
    % Default values are assigned during sequence allocation (AlpSeqAlloc). 
    % All timing parameters as well as some of their limits can be inquired
    % using the AlpSeqInquire function. It is allowed to change settings of
    % sequences that are currently in use. However the new settings beccome
    % effective after restart using AlpProjStart or AlpProjStartCont.
    % DeviceId:         ALP device identifier.
    % SequenceId:       ALP sequence identifier.
    % IlluminateTime:   duration of the display of one picture in the
    %                   sequence.
    % PictureTime:      time between the start of two consecutive pictures 
    %                   (i.e. this parameter defines the image display
    %                   rate).
    % SynchDelay:       specifies the time between start of the frame synch
    %                   output pulse and the start of the display (master 
    %                   mode).
    % SynchPulseWidth:  specifies the duration of the frame synch output 
    %                   pulse.
    % TriggerInDelay:   specifies the time between the incoming trigger edge and the start of the
    %                   display (slave mode).
    ret = calllib('ALP', 'AlpSeqTiming', DeviceId, SequenceId, IlluminateTime, PictureTime, ...
                           SynchDelay, SynchPulseWidth, TriggerInDelay);
    obj.checkError(ret);
end

function UserVar = AlpSeqInquire(obj, DeviceId, SequenceId, InquireType)
    % This function provides information about the settings of the 
    % specified picture sequence. The settings are controlled either during
    % allocation (AlpSeqAlloc) or using the AlpSeqControl and AlpSeqTiming
    % functions, respectively.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier.
    % InquireType:  specifies the sequence parameter setting to inquire.
    [ret, UserVar] = calllib('ALP', 'AlpSeqInquire', DeviceId, SequenceId, InquireType, 0);
    obj.checkError(ret);
end

function AlpSeqPut(obj, DeviceId, SequenceId, PicOffset, PicLoad, UserArray)
    % This function allows loading user supplied data via the USB 
    % connection into the ALP memory of a previously allocated sequence 
    % (AlpSeqAlloc) or a part of such a sequence. The loading operation can
    % run concurrently to the display of other sequences. Data cannot be 
    % loaded into sequences that are currently started for display. Note: 
    % This protection can be disabled by ALP_SEQ_PUT_LOCK. The function 
    % loads PicNum pictures into the ALP memory reserved for the specified 
    % sequence starting at picture PicOffset. The calling program is 
    % suspended until the loading operation is completed. The ALP API 
    % compresses image data before sending it over USB. This results in a 
    % virtual improvement of data transfer speed. Compression ratio is 
    % expected to vary depending on image data. Incompressible data do not 
    % cause overhead delays.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier.
    % PicOffset:    picture number in the sequence (starting at 0) where 
    %               the data upload is started; the meaning depends upon 
    %               ALP_DATA_FORMAT.
    % PicLoad:      number of pictures that are to be loaded into the 
    %               sequence memory. Depending on ALP_DATA_FORMAT different
    %               values are allowed (see PDF).
    % UserArray     user data to be loaded.
    ret = calllib('ALP', 'AlpSeqPut', DeviceId, SequenceId, PicOffset, PicLoad, UserArray);
    obj.checkError(ret);
end

function AlpSeqFree(obj, DeviceId, SequenceId)
    % This function frees a previously allocated sequence. The ALP memory 
    % reserved for the specified sequence in the device DeviceId is
    % released.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier.
    ret = calllib('ALP', 'AlpSeqFree', DeviceId, SequenceId);
    obj.checkError(ret);
end

function AlpProjControl(obj, DeviceId, ControlType, ControlValue)
    % This function controls the system parameters that are in effect for 
    % all sequences. These parameters are maintained until they are
    % modified again or until the ALP is freed. Default values are in 
    % effect after ALP allocation. All parameters can be read out using the 
    % AlpProjInquire function. This function is only allowed if the ALP is 
    % in idle wait state (ALP_PROJ_IDLE), which can be enforced by the 
    % AlpProjHalt function.
    % DeviceId:     ALP device identifier.
    % ControlType:  name of the control parameter.
    % ControlValue: value of the control parameter.
    ret = calllib('ALP', 'AlpProjControl', DeviceId, ControlType, ControlValue);
    obj.checkError(ret);
end

function UserVar = AlpProjInquire(obj, DeviceId, InquireType)
    % This function provides information about general ALP settings for the
    % sequence display.
    % DeviceId:     ALP device identifier.
    % InquireType:  select which information is to be inquired.
    [ret, UserVar] = calllib('ALP', 'AlpProjInquire', DeviceId, InquireType, 0);
    obj.checkError(ret);
end

function AlpProjControlEx(obj, DeviceId, ControlType, UserStruct)
    % Data objects that do not fit into a simple 32-bit number can be 
    % written using this function. These objects are unique to the ALP 
    % device, so they may affect display of all sequences. Meaning and 
    % layout of the data depend on the ControlType.
    % DeviceId:     ALP device identifier.
    % ControlType:  name of the control parameter.
    % UserStruct:   data structure whose values shall be send to the
    %               device. Structure must be a struct based on 
    %               obj.C.tFlutWrite!
    if isempty(fields(UserStruct))
        error('UserStruct must be based on the obj.C.tFlutWrite struct.')
    end
    try 
        UserStructPtr = libstruct('tFlutWrite', UserStruct);
    catch
        error('UserStruct must be based on the obj.C.tFlutWrite struct.')
    end
    ret = calllib('ALP', 'AlpProjControlEx', DeviceId, ControlType, UserStructPtr);
    obj.checkError(ret);  
end

function UserStruct = AlpProjInquireEx(obj, DeviceId, InquireType)
    % Data objects that do not fit into a simple 32-bit number can 
    % be inquired using this function. Meaning and layout of the 
    % data depend on the InquireType.
    % DeviceId:     ALP device identifier.
    % InquireType:  select which information is to be inquired, and
    %               select the data structure of UserStruct.
    UserStructPtr = 0;
    % Use pre-defined structure type as input
    if InquireType == obj.C.ALP_PROJ_PROGRESS
        UserStructTemplate = obj.C.tAlpProjProgress;
        UserStructPtr = libstruct('tAlpProjProgress', struct());
    end
    ret = calllib('ALP', 'AlpProjInquireEx', DeviceId, InquireType, UserStructPtr);            
    obj.checkError(ret);
    % Retrieve values
    UserStruct = get(UserStructPtr);
    % Make sure types are converted
    UserStructFields = fields(UserStruct);
    for i = 1:length(UserStructFields)
        fieldName = UserStructFields{i};
        fieldClass = class(UserStructTemplate.(fieldName));
        fieldValue = UserStruct.(fieldName);
        % Convert
        UserStruct.(fieldName) = cast(fieldValue, fieldClass);
    end
end

function AlpProjStart(obj, DeviceId, SequenceId)
    % A call to this function causes the display of the specified sequence 
    % that was previously loaded by the AlpSeqPut function. The sequence is
    % displayed with the number of repetitions controlled by ALP_SEQ_REPEAT 
    % (once by default). This can be interrupted prematurely using the 
    % AlpProjHalt function. The calling program gets control back 
    % immediately. Use AlpProjWait to synchronize your application if
    % required. The sequence usage flag (ALP_SEQ_IN_USE) is active for a 
    % sequence that is currently selected for display. Data cannot be 
    % loaded into this sequence (AlpSeqPut) and it cannot be freed. Timing
    % adjustments are active after restart of a sequence. A transition to 
    % the next sequence can take place without any gaps. See also the 
    % description of AlpProjStartCont for details.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier of the sequence to be
    %               displayed.
    ret = calllib('ALP', 'AlpProjStart', DeviceId, SequenceId);
    obj.checkError(ret);
end

function AlpProjStartCont(obj, DeviceId, SequenceId)
    % This function displays the specified sequence in an infinite loop. 
    % The sequence display can be stopped using AlpProjHalt or AlpDevHalt.
    % A transition to the next sequence can take place without any gaps, 
    % if a sequence display is currently active. Depending on the start 
    % mode of the current sequence, the switch happens after the completion
    % of the last repetition (controlled by ALP_SEQ_REPEAT, AlpProjStart), 
    % or after the completion of the current repetition (AlpProjStartCont). 
    % Only one sequence start request can be queued. Further requests are 
    % replacing the currently waiting request.
    % DeviceId:     ALP device identifier.
    % SequenceId:   ALP sequence identifier of the sequence to be
    %               displayed.
    ret = calllib('ALP', 'AlpProjStartCont', DeviceId, SequenceId);
    obj.checkError(ret);
end

function AlpProjHalt(obj, DeviceId)
    % This function can be used to stop a running sequence display and to 
    % set the ALP in idle wait state ALP_PROJ_IDLE. The running sequence 
    % loop is displayed until completion of the current iteration. This 
    % function returns immediately. Use AlpProjWait to recognize when the 
    % projection is finished.
    % DeviceId:     ALP device identifier.
    ret = calllib('ALP', 'AlpProjHalt', DeviceId);
    obj.checkError(ret);    
end

function AlpProjWait(obj, DeviceId)
    % This function is used to wait for the completion of the running 
    % sequence display. Using this function during the display of an 
    % infinite loop (AlpProjStartCont) causes the ALP_PARM_INVALID error 
    % return value. (This applies to ALP_PROJ_LEGACY mode only. See also
    % Inquire Progress of Active Sequences and Legacy Mode Behavior.)
    % AlpProjControl can adjust the timing with ControlType 
    % ALP_PROJ_WAIT_UNTIL.
    % DeviceId:     ALP device identifier.
    ret = calllib('ALP', 'AlpProjWait', DeviceId);
    obj.checkError(ret);
end

end

methods 

function delete(~)
    % Unload ALP-4 API       
    if libisloaded('ALP')
        unloadlibrary('ALP');
    end  
    fprintf('Unloaded ALP-4 library.\n')
end

end

end