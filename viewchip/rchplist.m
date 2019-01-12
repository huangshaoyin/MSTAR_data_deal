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
%        M-file: rchplist.m
%        Author: John F. Querns (Veridian, Veda Operations)
%          Date: 03 Mar 98
%
%                Based on rd_mstr by Steve Worrell (Wright State U.)...
%
%************************************************************************** 
% DESCRIPTION:
% This M-file function opens MSTAR target chip series list file and reads
% and processes the target chips in the list.  It expects the chip names
% to be listed 1 per line in the list file. It passes the target data
% back to the calling program (i.e. vwchip) for display.
%**************************************************************************


function [imgdata, numcol, numrow, numchips] = rchplist(chip_list);

fid = 1;
numchips = 0;     % Counter for number of chips to be processed...
    
imgwid = 0;
imghgt = 0;

% Array to hold header..initialize to blanks 
for i = 1:100
    header(i,:) = blanks(100);
end
     

%*********************************
%*  CHIP LIST HEADER SECTION     *
%*********************************

% Open and read target chip names from input list file..
fid1 = fopen(chip_list,'r'); 
while (fid ~= -1)

  numchips = numchips+1;
  tp = [];
  i = 0;

  chipname = fgets(fid1); 
  if(chipname == -1) 
    break
  end

  % Scan each chip filename read into chip_file_names array..
  chip_file_names(numchips,:) = sscanf(chipname,'%s');

  % Open each chip file for reading...
  fid = fopen(chip_file_names(numchips,:),'r');

  %
  % Read in all Phoenix Header Information... 
  % Load into matrix header until termination
  % condition is met [EndofPhoenixHeader]
  %

  while (strcmp(tp,'[EndofPhoenixHeader]') == 0)

    % Initialize variables...
    z1 = [];
    tp = [];

    % Get one header string from file...
    z1 = fgets(fid); 

    % Scan header string into temp variable tp...
    tp = sscanf(z1,'%s'); 

    % Load header string into header matrix (header)

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
    hdr_size_flag = strcmp(header(i,1:size(hdr_size_field,2)), hdr_size_field);
  end  

  hdrsize(numchips) = str2num(header(i,size(hdr_size_field,2)+1:size(header,2))); 

  % Extract NUMBER OF COLUMNS.... 
  numcol_field = 'NumberOfColumns=';
  numcol_flag = 0;
  i = 0;
  
  while(numcol_flag == 0)
    i = i+1;
    numcol_flag = strcmp(header(i,1:size(numcol_field,2)),numcol_field);
  end 

  numcol(numchips) = str2num(header(i,size(numcol_field,2)+1:size(header,2)));
  imgwid = imgwid + numcol(numchips);

  % Extract NUMBER OF ROWS.... 
  numrow_field = 'NumberOfRows=';
  numrow_flag = 0;
  i = 0;
  
  while(numrow_flag == 0)
    i = i+1;
    numrow_flag = strcmp(header(i,1:size(numrow_field,2)),numrow_field);
  end

  numrow(numchips) = str2num(header(i,size(numrow_field,2)+1:size(header,2))); 
  imghgt = imghgt + numrow(numchips);

  %
  % Close current target chip file
  %
  fclose(fid);

end

% Close input chip list file...
fclose(fid1); 
numchips = numchips - 1;

%*****************************************
%*  CHIP LIST IMAGE PROCESSING SECTION   *
%*****************************************

% DO for each file in list...
for i = 1:numchips;

    disp(['Processing chip image: ', chip_file_names(i,:)]);

    fid = fopen(chip_file_names(i,:),'rb','b');
    fseek(fid,hdrsize(i),'bof');

    % Read calibrated MAGNITUDE data...form REAL matrix..

    mag_vector = fread(fid,[numrow(i)*numcol(i)],'float32');
    imgdata(:,(i-1)*numrow(i)+1:i*numrow(i)) = reshape(mag_vector, ...
                                                       numcol(i), ...
                                                       numrow(i));
    % Close file..
    fclose(fid);

end
