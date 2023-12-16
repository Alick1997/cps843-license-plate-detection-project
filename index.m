%CPS843 Project Entry File

scriptPath = fileparts(mfilename('fullpath'));
imageFolder = fullfile(scriptPath, '/resources/images');

% Get a list of all files in the folder
imageFiles = dir(fullfile(imageFolder, '*.png'));

licensePlateTexts = {};

for i = 1:length(imageFiles)
    imagePath = fullfile(imageFolder, imageFiles(i).name);
    
    img = imread(imagePath);
    figure; 
    imshow(img); 
    h = drawrectangle; %draw rectangle around area with text
    roi = round(h.Position); %generate region of interest from rectangle
    ocrRes = ocr(img, roi); %perform ocr on region of interest
    licensePlateTexts{end+1} = ocrRes.Text; %extract text from ocr result

    %display results
    figure; 
    Iocr = insertText(img,roi(1:2),ocrRes.Text,AnchorPoint="RightTop",FontSize=16);
    imshow(Iocr)
    title(['License Plate for Image ', ocrRes.Text]); % Title with license plate text
    
    % display result in command 1 by one
    fprintf('License Plate Text for Image %d: %s\n', i, ocrRes.Text);
end

% Display all extracted license plate numbers
disp('All Extracted License Plate Texts:');
disp(licensePlateTexts);
