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
%        M-file: vwchip
%        Author: John F. Querns (Veridian, Veda Operations)
%          Date: 03 Mar 98
%
%                Based on rd_mstr by Steve Worrell (Wright State U.)...
%
%************************************************************************** 
% DESCRIPTION:
% This M-file displays either a single MSTAR target chip file or a series of
% target chips. The displayed data is read in from the MAGNITUDE portion of
% the input image file(s).  The magnitude data has a datatype of 32-bit float
% and units of meters.
%  
% This routine prompts the user for input data, processes the clutter header,
% forms the image matrix, and, finally, displays the image.
%
%**************************************************************************

% Initialize
clear all

% Define some flags..
single_type = 1;  % Single chip input option..
list_type   = 2;  % List of chips input option..

%************************************************************************
%*                             INPUT  SECTION                           *
%************************************************************************

% Prompt user for list or single file input...
disp(' ');
in_opt = input('Input type [1=Single chip, 2=List of chips]: ');

% Process input prompt...
if(in_opt == single_type)

   % Prompt for input target chip filename..
   disp(' ');
   chip_file = input('Name of target chip file: ','s');

elseif(in_opt == list_type)

   % Prompt for input target chip list file..
   disp(' ');
   chip_list = input('Name of file containing list of target chips: ','s');

   disp(' ');
   disp(' ');
   disp('**************************** WARNING ******************************');
   disp('Large MSTAR target chip lists may take a long time to display');
   disp('on some processors...memory may also run out');
   disp('**************************** WARNING ******************************');
   disp(' ');
   disp('Processing chips in list...');
   disp(' ');

else

   disp(' ');
   error('Error: Incorrect input option..should be 1=single or 2=list');
   disp(' ');
   disp(' ');

end


%************************************************************************
%               PROCESS BASED on SINGLE or LIST TYPE                    *
%************************************************************************

if (in_opt == list_type)

   % Call EXTERNAL FUNCTION to process list data...
   [imgdata, numcol, numrow, numchips] = rchplist(chip_list);

else

   %*********************************
   %*  SINGLE CHIP HEADER SECTION   *
   %*********************************

   % Initializing some things...
   fid      = 1;
   tp       = [];
   numchips = 1;
    
   for i = 1:100
       header(i,:) = blanks(100);  % Array to hold Phoenix header..
   end
 
   % Open target chip for reading...
   fid = fopen(chip_file(1,:),'r');

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


   %*******************************************
   %*  SINGLE CHIP IMAGE PROCESSING SECTION   *
   %*******************************************

   disp(['Processing chip image: ', chip_file]);
   disp(' ');

   % Seek to start of clutter scene image data..
   fseek(fid,hdrsize,'bof');

   % Read calibrated MAGNITUDE data...form REAL matrix..
   imgdata = fread(fid,[numcol*numrow],'float32');
   imgdata = reshape(imgdata,numcol,numrow); 

   % Matlab pixels start from 1 so we transpose image and add 1 to it..
   imgdata     = imgdata' + 1;

   % Close file..
   fclose(fid);

end 


%************************************************************************
%*                   MAIN ROUTINE DISPLAY SECTION                       *
%************************************************************************

% Put up output display window...
disp(' ');
figure(1)

% If LIST OF CHIPS...
if (in_opt == list_type)

   % Set up grayscale colortable based on default graymap..
   colormap(gray(256));

   % Determine how many rows/cols in series subplot..
   M = sqrt(numchips);

   % Display list of chips..
   for i = 1:numchips
     subplot(ceil(M),ceil(M), i);
     imagesc(log10(abs(imgdata(:,(i-1)*numrow(i)+1:i*numrow))+1))
    
     % Set Axis Parameters..
     axis image;             % Use image wid to hgt aspect ratio..
     axis off;               % Turn off axis labeling..
   end

   % Brighten a little..
   brighten(0.3);

else 

   % SINGLE CHIP DISPLAY...
   
   % Create contrast enhancing colormap...
   contrastmap = contrast(imgdata, 256);
   colormap(contrastmap);

   %Display log10(val+1) scaled image..in 2x2 subplot window..  
   subplot(2,2,1), imagesc((abs(imgdata(:,:)) + 1));

   %Set Axis Parameters...
   axis image;              % Use image wid to hgt aspect ratio..
   axis off;                % Turn off axis labeling..

end
% Last line of vw_chip.m
