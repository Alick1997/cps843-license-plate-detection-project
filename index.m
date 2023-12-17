%CPS843 Project Entry File

scriptPath = fileparts(mfilename('fullpath'));
imageFolder = fullfile(scriptPath, '/resources/images');

% Get a list of all files in the folder
imageFiles = dir(fullfile(imageFolder, '*.png'));

licensePlateTexts = {};

%1 - Import video
foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50);

%videoReader = VideoReader('visiontraffic.avi');
videoReader = VideoReader('C:\Users\Da Min\Documents\MATLAB\CPS843 labs\news.mp4');
for i = 1:150
    frame = readFrame(videoReader); % read the next video frame
    foreground = step(foregroundDetector, frame);
end

%
figure; imshow(frame); title('Video Frame');

figure; imshow(foreground); title('Foreground');

%detect cars with provided filtered foreground
se = strel('square', 3);
filteredForeground = imopen(foreground, se);
figure; imshow(filteredForeground); title('Clean Foreground');

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);
bbox = step(blobAnalysis, filteredForeground);

%draw green boxes around cars
result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');

%draw boxes around texts
ocrResults = ocr(frame)
Iocr = insertObjectAnnotation(frame,"rectangle", ...
            ocrResults.WordBoundingBoxes,ocrResults.Words,LineWidth=5,FontSize=72);
figure; imshow(Iocr); title('OCR')


figure; imshow(result); title('Detected Cars')

%show number of cars in frame: upper left
numCars = size(bbox, 1);
result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
    'FontSize', 14);
figure; imshow(result); title('Number of Detected Cars');

%rest of vido frames
videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650,400];  % window size: [width, height]
se = strel('square', 3); % morphological filter for noise removal

while hasFrame(videoReader)

    frame = readFrame(videoReader); % read the next video frame

    % Detect the foreground in the current video frame
    foreground = step(foregroundDetector, frame);

    % Use morphological opening to remove noise in the foreground
    filteredForeground = imopen(foreground, se);

    % Detect the connected components with the specified minimum area, and
    % compute their bounding boxes
    bbox = step(blobAnalysis, filteredForeground);

    % Draw bounding boxes around the detected cars
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');

    % Display the number of cars found in the video frame
    numCars = size(bbox, 1);
    result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
        'FontSize', 14);

    step(videoPlayer, result);  % display the results
end

for i = 1:length(imageFiles)
    imagePath = fullfile(imageFolder, imageFiles(i).name);
    img = imread(imagePath);
    grayImg = rgb2gray(img);
    enhancedImg = imadjust(grayImg); % Adjust contrast
    [imgHeight, imgWidth, ~] = size(img);
    figure; 
    imshow(enhancedImg); 
    h = drawrectangle; %draw rectangle around area with text
    roi = round(h.Position); %generate region of interest from rectangle
    ocrRes = ocr(enhancedImg, roi); %perform ocr on region of interest
    licensePlateTexts{end+1} = ocrRes.Text; %extract text from ocr result

    %display results
    figure; 
    Iocr = insertText(enhancedImg,[imgWidth * 0.5 imgHeight * 0.5],ocrRes.Text,AnchorPoint="RightTop",FontSize=16);
    imshow(Iocr);
    title(['License Plate for Image ', ocrRes.Text]); % Title with license plate text
    
    % display result in command 1 by one
    fprintf('License Plate Text for Image %d: %s\n', i, ocrRes.Text);
end

% Display all extracted license plate numbers
disp('All Extracted License Plate Texts:');
disp(licensePlateTexts);
