clear all 
ReadPath = 'D:\Document\Graduation Project\MSTAR\DAA7B02AA\TARGETS\TEST\15_DEG\T72\SN_S7\';
SavePath = 'D:\Document\Graduation Project\MSTAR\DAA7B02AA\TARGETSJPG\TEST\15_DEG\T72\SN_S7\';
%FileType = '*.017';


Files = dir(ReadPath);
NumberOfFiles = length(Files);
my_num=NumberOfFiles-2;
sar_data=zeros(my_num,128,128);

for k=3:3
%FID = fopen(ReadPath,'rb','ieee-be');

 clut_file=Files(k).name;
s2=strcat(ReadPath,clut_file(1,:));

 FID=1;
 
FID = fopen(s2,'rb','ieee-be');
    ImgColumns = 0;
    ImgRows = 0;
    while ~feof(FID)                                % 在PhoenixHeader找到图片尺寸大小
        Text = fgetl(FID);
        if ~isempty(strfind(Text,'NumberOfColumns'))
            ImgColumns = str2double(Text(18:end));
            Text = fgetl(FID);
            ImgRows = str2double(Text(15:end));
            break;
        end
    end
    while ~feof(FID)                                 % 跳过PhoenixHeader
        Text = fgetl(FID);
        if ~isempty(strfind(Text,'[EndofPhoenixHeader]'))
            break
        end
    end
    Mag = fread(FID,ImgColumns*ImgRows,'float32','ieee-be');
    Mag1 = fread(FID,ImgColumns*ImgRows,'float32','ieee-be');
    Img = reshape(Mag,[ImgColumns ImgRows]);
    Img1 = reshape(Mag1,[ImgColumns ImgRows]);
    
    
   sar_data(k-2,:,:)=Img(:,:);


    figure,
    imagesc( Img);

end

