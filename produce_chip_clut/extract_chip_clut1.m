

ReadPath_chip = '';


ReadPath_cult = '';

SavePath = '';


Files = dir(ReadPath_chip);
NumberOfFiles = length(Files);
my_num=NumberOfFiles-2;

cult=load(ReadPath_cult);
cult=cult.my_imgdata;
k=3;
for k=8%NumberOfFiles
 clut_file=Files(k).name;
s2=strcat(ReadPath_chip,clut_file(1,:));

sar_data=load(s2);
sar_data=sar_data.sar_data;
%sar_data=sar_data.sar_data_15;
[num,row,col]=size(sar_data);



end
num2=70;
my_rand=rand(1784,1476);
my_rand(:,1:num2)=0;
my_rand(:,1476-num2:1476)=0;
my_rand(1:num2,:)=0;
my_rand(1784-num2:1784,:)=0;
my_rand(find(my_rand<0.99995))=0;
%my_rand(find(my_rand>0.1))=1;
[row,col]=find(my_rand>0.1);

row(row==0) = [];
col(col==0) = [];

psi_num=size(row);
for i=1:psi_num(1,1);
   if row(i,1)~=0
       for j=(i+1):psi_num(1,1)
     
         if abs(row(i,1)-row(j,1))<98
             if abs(col(i,1)-col(j,1))<98
                row(j,1)=0;
                col(j,1)=0;
             end
         end
        end
    end
end
row(row==0) = [];
col(col==0) = [];

truth_num=size(row);

my_cult=cult;

my_test=sar_data(1,:,:);

figure,
num1=128;
 test=zeros(num1,num1);

test(:,:)=sar_data(3,:,:);
%colormap(gray(256));
%test(find(test<0.15))=0;
imagesc(test)
save 'test.mat' test '-v7.3'

my_test=43*my_test+1;
my_test=log10(my_test+1);
xmax = max(max(my_cult)); %求得InImg中的最大值
xmin = min(min(my_cult)); %求得InImg中的最小值
for i=1:truth_num(1,1)
  my_cult(row(i,1)-64:row(i,1)+63,col(i,1)-64:col(i,1)+63)=log10(215*sar_data(i,:,:)+2);
 %my_cult(row(i,1)-64:row(i,1)+63,col(i,1)-64:col(i,1)+63)=log10(sar_data(i,:,:)+2);

end

figure,
colormap(gray(256));
imagesc(my_cult)
axis image;        % Retain wid to hgt image aspect..
axis off;          % Turn off axis labelling..


brighten(0.5);





