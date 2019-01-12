%***************************************************************************
% THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS."
% THE U.S. GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
% CONCERNING THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING,
% WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
% PARTICULAR PURPOSE. IN NO EVENT WILL THE U.S. GOVERNMENT BE LIABLE FOR
% ANY DAMAGES, INCLUDING ANY LOST PROFITS, LOST SAVINGS OR OTHER
% INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE, OR INABILITY
% TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
% INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES."
%***************************************************************************
%
%        M-file: vwclut 
%        Author: John F. Querns (Veridian, Veda Operations)
%          Date: 03 Mar 98
%
%                Based on rd_mstr by Steve Worrell (Wright State U.)...
%
%************************************************************************** 
% DESCRIPTION:
% This routine prompts the user for input data, processes the clutter header,
% forms the image matrix, and, finally, displays the image. The displayed 
% image represents the MAGNITUDE data portion of the clutter scene, which is
% layed out in polar complex (mag+phase) format.
%
% NOTE:
% The MAGNITUDE image is not in its native (i.e. unsigned short) format, but
% has been normalized and scaled by calibration factors, giving you a
% magnitude that is proportional to the RCS of the scene resolution cell,
% with units of meters..
%**************************************************************************

clear all

%************************************************************************
%*                             INPUT  SECTION                           *
%************************************************************************

% Prompt for input clutter scene filename..
clut_file = input('Enter clutter scene filename: ','s');

data_type_str = 'Magnitude';

disp(' ');
disp(' ');
disp('**************************** WARNING ******************************');
disp('MSTAR Clutter scenes are LARGE and may take a long time to display');
disp('on some processors...');
disp('**************************** WARNING ******************************');
disp(' ');
disp(['Reading MSTAR clutter scene: ', clut_file]);
disp(['          Display Data Type: ',data_type_str]); 
disp(' ');
disp('Processing Phoenix header...');


%************************************************************************
%*                   PHOENIX HEADER PROCESSING SECTION                  *
%************************************************************************

% Initialize some things...
fid = 1;
tp = [];
    
for i = 1:100
    header(i,:) = blanks(100);  % Array to hold Phoenix header..
end
 
% Open clutter scene for reading...
fid = fopen(clut_file(1,:),'r');

%* Read Phoenix header..extract parameters.. 
while (strcmp(tp,'[EndofPhoenixHeader]') == 0)
  % Get one header string from file...
  z1 = [];
  z1 = fgets(fid); 

  % Scan header string into temp variable tp...
  tp = sscanf(z1,'%s'); 

  % Load header string into header matrix (header)...if non-empty
  if(isempty(tp) == 0)
    i = i+1;
    header(i,:) = zeros(1,100);
    header(i,1:(size(tp,2))) = tp;  
  end
end

% Calculate HEADER SIZE (in bytes)...
hdr_size_field = 'PhoenixHeaderLength=';
hdr_size_flag = 0;
i = 0;

while(hdr_size_flag == 0)
  i = i+1;
  hdr_size_flag = strcmp(header(i,1:size(hdr_size_field,2)),hdr_size_field);
end  

hdrsize = str2num(header(i,size(hdr_size_field,2)+1:size(header,2))); 
hdrsize = hdrsize + 512;  % Add 512 for native C4PL hdr..

% Extract NUMBER OF COLUMNS.... 
numcol_field = 'NumberOfColumns=';
numcol_flag = 0;
i = 0;
  
while(numcol_flag == 0)
  i = i+1;
  numcol_flag = strcmp(header(i,1:size(numcol_field,2)),numcol_field);
end 

numcol = str2num(header(i,size(numcol_field,2)+1:size(header,2)));

% Extract NUMBER OF ROWS.... 
numrow_field = 'NumberOfRows=';
numrow_flag = 0;
i = 0;
  
while(numrow_flag == 0)
  i = i+1;
  numrow_flag = strcmp(header(i,1:size(numrow_field,2)),numrow_field);
end 
 
numrow = str2num(header(i,size(numrow_field,2)+1:size(header,2))); 

% Extract SENSOR CALIBRATION FACTOR...
sensor_cal_field = 'SensorCalibrationFactor=';
sensor_cal_flag = 0;
i = 0;
     
while(sensor_cal_flag == 0)
  i = i+1;
  sensor_cal_flag = strcmp(header(i, ...
                                  1:size(sensor_cal_field,2)), ...
                                  sensor_cal_field);
end
 
calfactor = str2num(header(i,size(sensor_cal_field,2)+1:size(header,2))); 


%************************************************************************
%*                        IMAGE PROCESSING SECTION                      *
%************************************************************************

disp('Processing image data...');
disp(' ');
disp([' Num Rows (hgt): ', num2str(numrow)]); 
disp([' Num Cols (wid): ', num2str(numcol)]); 
disp(' ');
disp(' ');

% Seek to start of clutter scene image data..
fseek(fid,hdrsize,'bof');

% Form normalization scale factor...
scalefactor = calfactor/65535;

% Form MAGNTIUDE image data...
imgdata = fread(fid,[numcol*numrow],'ushort');
imgdata = scalefactor * reshape(imgdata,numcol,numrow); 

% Matlab pixels start from 1 so we transpose image and add 1 to it..
imgdata     = imgdata' + 1;

% Close file..
fclose(fid);


%************************************************************************
%*                            DISPLAY SECTION                           *
%************************************************************************

% Put up output display window...
figure(1);

% Set up a colortable..use default gray map
colormap(gray(256));

% Display log10(val+1) scaled image..
imagesc(log10(abs(imgdata(:,:)) + 1))
 
% Set AXIS Parameters...
axis image;        % Retain wid to hgt image aspect..
axis off;          % Turn off axis labelling..

% Brighten image...
brighten(0.5);

% Last line of vw_clut.m
