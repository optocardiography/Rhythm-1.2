function drawFrame(frame, camNo, handles)
    for i=1:4
        handles.allCamData(i).screen.XColor = 'black';
        handles.allCamData(i).screen.YColor = 'black';
    end
    handles.activeScreen.XColor = 'red';
    handles.activeScreen.YColor = 'red';
    
    if handles.allCamData(camNo).isloaded==1 
        if ~handles.allCamData(camNo).drawMap    
            G = handles.allCamData(camNo).bgRGB;
            
            if (frame <= handles.allCamData(camNo).maxFrame)
                frame_index = frame;
            else
                frame_index = size(handles.allCamData(camNo).cmosData, 3);
            end
            
            if handles.allCamData(camNo).drawPhase == 0
                Mframe = handles.allCamData(camNo).cmosData(:,:,frame_index);
            else
                Mframe = handles.allCamData(camNo).cmosPhase(:,:,frame_index);
            end
            
            J = real2rgb(Mframe, 'jet');
            
            A = (Mframe >= handles.normalizeMinVisible);  
            if all(A(:))
                A = real2rgb(A,'gray');
                A = ones(size(A));
            else
                A = real2rgb(A,'gray');
            end
            
            I = J .* A + G .* (1 - A);

            if handles.activeScreenNo == camNo
                if (handles.drawSegmentation)
                    mask = handles.activeCamData.finalSegmentation;
                    maskedI = I;
                    [row,col] = find(mask~=0);
                    for i=1:size(row,1)
                        maskedI(row(i),col(i),1) = 1;
                    end
                    image(maskedI,'Parent',handles.activeScreen);
 
                else
                    image(I,'Parent',handles.activeScreen);
                end
            
            else
                image(I,'Parent',handles.allCamData(camNo).screen);
            end
        end
        
        if handles.bounds(camNo) == 1
            M = handles.markers1;
        elseif handles.bounds(camNo) == 2
            M = handles.markers2;
        else
            M = handles.allCamData(camNo).markers;
        end
        [a,~]=size(M);
        hold (handles.allCamData(camNo).screen,'on');
   
        %TODO �������� ����� ����� �������� maskedI ��� I

        for x=1:a
            plot(M(x,1),M(x,2),'wp','MarkerSize',12,'MarkerFaceColor',...
                handles.markerColors(x),'MarkerEdgeColor','w','Parent',handles.allCamData(camNo).screen);
            
            set(handles.allCamData(camNo).screen,'YTick',[],'XTick',[]);% Hide tick markes
        end
        hold (handles.allCamData(camNo).screen,'off')       
        
    end
end


