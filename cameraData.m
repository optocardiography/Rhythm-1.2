% Handle class for camera data loaded into a movie screen
% by Roman Pryamonosov

classdef cameraData < handle
    properties
        isloaded=0;
        
        isVisible=1;
        
        maxFrame=0;
        
        screenPos = [];
        expandedScreenPos = [];
        
        colorbar = [];
        cmosData = [];
        rawData = [];
        bg=[];
        ecg=[];
        cmosRawData=[];
        bgRGB=[];
        Fs=[];
        saveData=[];
        actMap =[];
        VecArray = [];
        
        screen=[];
        
        time = [];
        cmap = colormap('Jet'); %saves the default colormap values
        
        frame=1;% this handles indicate the current frame being displayed by the movie screen
        movie_img=[];
        playback=0;
        
        % functional for markers
        markers = []; % this handle stores the locations of the markers
        wave_window = 1;
        grabbed = -1;
        
        c_start = 0;
        c_end = 0;
        a_start = 0;
        a_end = 0;
        
        %for saving CV map
        saveX_plot = [];
        saveY_plot = [];
        saveVx_plot = [];
        saveVy_plot = [];
        
        %for saving new CV map
        saveX_newCV = [];
        saveY_newCV = [];
        saveVx_newCV = [];
        saveVy_newCV = [];
        
        %statistics
        meanresults = sprintf('Mean:');
        medianresults = sprintf('Median:');
        SDresults = sprintf('S.D.:');
        num_membersresults =sprintf('#Members:');
        angleresults =sprintf('Angle:');
        
        %resolution. Used for CV now, probably we should use it for
        %different functions as well.
        xres=0;
        yres=0;
         
        xFlip = 0;
        yFlip = 0;
        
        drawMap = 0;
        lastMapMode=0;
        %numOfContourLevels = 1;
        segmentation = [];
    end
end
