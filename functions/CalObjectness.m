    % ----------------------------------------------------------------
    % function CalUniqueness
    % input:  I ............Input image
    % output: ObjectMap.....Output Objectness Map
    % implementation of function runObjectness, see:
    % Alexeet al., Measuring the objectness of image windows. PAMI, 2012
    % for details
    % ----------------------------------------------------------------

    function [ ObjectMap ] = CalObjectness( I )
        
        [Height Width Channel] = size(I);
        ObjectMap=zeros(Height,Width);
        boxes = runObjectness(I,10000);
        boxes = sortrows(boxes,5);    

        for idx = 1:size(boxes,1)
            xmin = uint16(boxes(idx,1));
            ymin = uint16(boxes(idx,2));
            xmax = uint16(boxes(idx,3));
            ymax = uint16(boxes(idx,4));
            score = boxes(idx,5);
            temp=zeros(Height,Width);
            temp(ymin:ymax,xmin:xmax)=score;
            ObjectMap=ObjectMap+temp;
        end
        ObjectMap=uint8(mat2gray(ObjectMap)*255);
 
    end
