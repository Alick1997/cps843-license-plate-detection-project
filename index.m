%CPS843 Project Entry File

scriptPath = fileparts(mfilename('fullpath'));
imageFolder = fullfile(scriptPath, '/resources/images');

% Get a list of all files in the folder
imageFiles = dir(fullfile(imageFolder, '*.png')); % Change '*.jpg' to the appropriate format if needed

% Initialize a cell array to store the extracted text
licensePlateTexts = {};

% Loop over each image file
for i = 1:length(imageFiles)
    % Full path to image
    imagePath = fullfile(imageFolder, imageFiles(i).name);
    
    % Read the image
    img = imread(imagePath);
    figure; % Create a new figure window
    imshow(img); % Show the image
    h = drawrectangle; % Let the user draw a rectangle
    roi = round(h.Position); % Get the position of the rectangle
    %roi = round(getPosition(drawrectangle))
    % Perform OCR
    ocrRes = ocr(img, roi);
    
    % Store the recognized text
    licensePlateTexts{end+1} = ocrRes.Text;

       % Display the image
    figure; % Create a new figure window
    Iocr = insertText(img,roi(1:2),ocrRes.Text,AnchorPoint="RightTop",FontSize=16);
    imshow(Iocr)
    title(['License Plate for Image ', ocrRes.Text]); % Title with image number
    
    % Optionally, you can display each plate's text
    fprintf('License Plate Text for Image %d: %s\n', i, ocrRes.Text);
end

% Display all extracted texts
disp('All Extracted License Plate Texts:');
disp(licensePlateTexts);
