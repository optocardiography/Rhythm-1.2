% Handle class for signal pannels that used to draw signal waves in
% sychronized movie screen mode 
% 
% by Roman Pryamonosov

classdef signalPanelHandles < handle
    properties
        isloaded=0;
        
        isVisible=1;
        Num = []
        panel = uipanel('Units','normalized', 'Visible','off');    
        signalScreen = [];
        sweepBar = [];
    end
end
