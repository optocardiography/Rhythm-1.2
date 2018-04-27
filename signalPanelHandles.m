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
