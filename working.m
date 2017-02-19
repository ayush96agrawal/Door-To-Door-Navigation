function [adjMatrix, vertices, numOfDoors, doors] = working(img,s)
    adjMatrix = [];
    vertices = [];
    %s = xml2struct('C:\Users\Ayush Agrawal\Desktop\BTP\file_3.xml');
    %img=imread('C:\Users\Ayush Agrawal\Desktop\BTP\file_3.tiff');
    numOfNodes = 1;
    numOfObjects = 1;
    for i=1:str2double(s.gom_dot_OHL.ov.Attributes.size)
        temp = strcat(s.gom_dot_OHL.ov.o{i}.gom_dot_std_dot_OSymbol.Attributes.label,'extra');
        if (strcmp(temp(1:4),'door') == 1)
            doors(numOfNodes)=struct(s.gom_dot_OHL.ov.o{i}.gom_dot_std_dot_OSymbol.Attributes);
            numOfNodes = numOfNodes + 1;
        else
            objects(numOfObjects)=struct(s.gom_dot_OHL.ov.o{i}.gom_dot_std_dot_OSymbol.Attributes);
            numOfObjects = numOfObjects + 1;
        end
    end
    for i=1:str2double(s.gom_dot_OHL.av.Attributes.size)
        temp = strcat(s.gom_dot_OHL.av.a{i}.gom_dot_std_dot_OSymbol.Attributes.label,'extra');
        if (strcmp(temp(1:4),'door') == 1)
            doors(numOfNodes)=struct(s.gom_dot_OHL.av.a{i}.gom_dot_std_dot_OSymbol.Attributes);
            numOfNodes = numOfNodes + 1;
        else
            objects(numOfObjects)=struct(s.gom_dot_OHL.av.a{i}.gom_dot_std_dot_OSymbol.Attributes);
            numOfObjects = numOfObjects + 1;
        end
    end
    numOfNodes = numOfNodes - 1;
    numOfObjects = numOfObjects - 1;
    numOfDoors = numOfNodes;
    %vertices = [];
    for i=1:numOfNodes
        if (str2double(doors(i).direction) == 0)
            vertices=[vertices;(str2double(doors(i).x0)+str2double(doors(i).x1))/2, str2double(doors(i).y1)];
        elseif (str2double(doors(i).direction) == 90)
            vertices=[vertices;str2double(doors(i).x0), (str2double(doors(i).y0)+str2double(doors(i).y1))/2];
        elseif (str2double(doors(i).direction) == 180)
            vertices=[vertices;(str2double(doors(i).x0)+str2double(doors(i).x1))/2, str2double(doors(i).y0)];
        elseif (str2double(doors(i).direction) == 270)
            vertices=[vertices;str2double(doors(i).x1), (str2double(doors(i).y0)+str2double(doors(i).y1))/2];
        else
            vertices=[vertices;(str2double(doors(i).x0)+str2double(doors(i).x1))/2, (str2double(doors(i).y0)+str2double(doors(i).y1))/2];
        end
    end
    for i=1:numOfObjects
        vertices=[vertices;str2double(objects(i).x0), str2double(objects(i).y0)];
        vertices=[vertices;str2double(objects(i).x0), str2double(objects(i).y1)];
        vertices=[vertices;str2double(objects(i).x1), str2double(objects(i).y0)];
        vertices=[vertices;str2double(objects(i).x1), str2double(objects(i).y1)];
    end
    im = img;
    for i=1:numOfDoors
        for j=round(str2double(doors(i).x0)):round(str2double(doors(i).x1))
            for k=round(str2double(doors(i).y0)):round(str2double(doors(i).y1))
                im(k,j) = 255;
            end
        end
    end
    I=im;
    for i=1:numOfObjects
        for j=round(str2double(objects(i).x0)):round(str2double(objects(i).x1))
            for k=round(str2double(objects(i).y0)):round(str2double(objects(i).y1))
                im(k,j) = 0;
            end
        end
    end
    %im = imgaussfilt(im,[4 4]);
    %I = imdilate(img,strel('disk',10));
    %I = imerode(I,strel('square',17));
    corners = detectHarrisFeatures(im);
    corners=corners.selectStrongest(1000);
    corners = corners.Location;
    vertices=[vertices;corners];
    numOfNodes = numOfNodes + size(corners,1) + 4*numOfObjects;
    %I = imdilate(I,strel('disk',2));
    %im = imerode(im,strel('disk',1));
    im = imdilate(im,strel('disk',2));
    %adjMatrix = [];
    for i=1:numOfNodes
        for j=1:numOfNodes
            if (i ==j)
                adjMatrix(i,j) = 0;
            elseif (isvisible(vertices(i,:),vertices(j,:),im))
                adjMatrix(i,j) = sqrt(((vertices(i,1)-vertices(j,1)).^2) +((vertices(i,2)-vertices(j,2)).^2));
            else
                adjMatrix(i,j) = 0;
            end
        end
    end
end