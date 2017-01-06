% © R Hyde 2016 Manchester University
% Released under the GNU GPLver3.0
% Coded on Matlab 2016b, but should work on many earlier versions.
% This script reads a custom Manchester University Mavlink message. The
% message has been created by reading standard mavlink data from a PixHawk
% using an attached Teensy3.5. The Teensy reads also reads sensor data and
% combines all the information to a new Mavlink message. This is then sent
% to ground via 3DR telemtry radios. This script reads the serial data from
% the 3DR ground radio via serial port and decodes it.
% We only expect a single message type of known length. The data is
% displayed in an on-screen array and updated with each message. This
% allows for comparisons between the data received and the data sent if
% using VisualMicro in debugging mode for your arduino code.
%
% To find the relevant data names and types for your own messages, refer to
% the "mavlink_msg_XXX.h" message definitions and construct your own decode function
% for the message.

clear all

delete(instrfind)
%% Create serial port object
Port = serial('COM16'); % change the COM Port number as needed
Baud = 57600;
Port.InputBufferSize = 512; % default value, allows for over-runs
try
    set(Port,'BaudRate',Baud);
    fopen(Port);
catch err
    fclose(instrfind);
    error('Make sure you select the correct COM Port.');
end
%% Limit duration during testing
Tmax = 60; % Total time for data collection (s)
tic % Start timer

%% on screen display
Show = figure(1);
clf
DisplayTable = uitable(Show,'Units','norm','Pos',[0,0,0.5,1],...
    'Data', {'Waiting...', '<html><tr><td align=right  width=9999>n/a'});
DisplayTable.ColumnName = {'Value', 'Units'}'; % column headings
DisplayUpdate = 0; % flag to on;y update display if message received and decoded

%% set port to allow asynchronous read. Required to read data in different
% formats and continue processing or other tasks while waiting for data
readasync(Port);

while toc <= Tmax

    %% Asynchronous port reading allows processing to continue if required 
    % instead of waiting for data. It also means that when the required
    % number of bytes are received we can read them in the correct formats.
    
    if Port.bytesavailable == 90 % check if full message arrived
        % here we only expect a single message type of known length.
        % Something more complicated is required for multiple messages in 
        % unknown order.
        
        % Read the MavLink packet info
        StartOfFrame = fread(Port, 1); % first byte
        PayloadLength = fread(Port, 1); % number of bytes of the payload
        PacketSequence = fread(Port, 1); % 
        SystemID = fread(Port, 1); % system_id of the system that sent the packet
        ComponentID = fread(Port, 1); % component _id of the system that sent the packet
        MessageID = fread(Port, 1); % message ID that describes the type of Mavlink message packet
        [msgData, DataUnits] = readpayload(Port, MessageID); % fuction to read the data into a structure
        
        CRC = fread(Port, 2); % CRC value to check data integrity (not used here)
        DisplayUpdate = 1;
    end
    
    
    %% Display message data on screen
    if DisplayUpdate == 1
    DataNames = fieldnames(msgData); % names for first column
    DisplayTable.RowName = DataNames; % display the names
    
    DataValues = struct2cell(msgData); % data for 2nd column
    DataUnits=DataUnits'; % data units
     % workaround to right justify units column for clarity
    Justify=repmat({'<html><tr><td align=right  width=9999>'},size(DataUnits,1),1);
    DisplayUnits=strcat(Justify,DataUnits);
    DisplayTable.Data = [DataValues, DisplayUnits]; % display the data
    DisplayUpdate=0;
    drawnow
    end
        
end
fclose(Port);

function [msgData, DataUnits]=readpayload(Port, MessageID)
% This function reads the MavLink message payload into a structure. The
% field names and data types are found in the c++ header file used to
% define the message. Typically "mavlink_msg_XXX.h" and loaded through the
% "common.h" file.

    switch MessageID
        case 225 % UoM Atmospheric Data
            
        %List of data field names, see mavlink definition for units
        FieldNames={'Roll', 'Pitch', 'Yaw', 'RollSpeed', 'PitchSpeed', 'Yawpeed',...
            'TimeBoot', 'Lat', 'Lon', 'Alt', 'RelativeAlt', 'AirSpeed', 'GroundSpeed', ...
            'PressureAbs', 'PressureDiff', 'OP1', 'OP2', 'CO', 'VX', 'VY', 'VZ', ...
            'heading', 'temperature'};
        
        % List of data types
        DataTypes={'float', 'float', 'float', 'float', 'float', 'float', 'uint32', ...
            'int32', 'int32', 'int32', 'int32', 'float', 'float', 'float', 'float', ...
            'float', 'float', 'float', 'int16', 'int16', 'int16', 'int16', 'int16'};
        
        % List of units
        DataUnits={'rads', 'rads', 'rads', 'rad/s', 'rad/s', 'rad/s',...
            'ms', '*1E7', '*1E7', 'mm', 'mm', 'm/s * 100', 'm/s * 100',...
            'hP', 'hP', 'mV', 'mV', 'ppb', 'm/s', 'm/s', 'm/s', 'Deg', 'deg C * 100', };
        
        % Read the data into msgData structure
        for idx1 = 1 : size(FieldNames, 2)
            msgData.(FieldNames{idx1}) = fread(Port, 1, DataTypes{idx1});
        end
    end
end