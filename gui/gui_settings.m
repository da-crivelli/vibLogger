function gui_settings = gui_settings()
    buttons_list = containers.Map;
    buttons_list('e02') = struct('label', 'E02', ...
                            'path', '\\dc\dls\science\groups\vibration\monitoring\ebic\e02\',...
                            'description', 'eBIC E02 room, under cable tray');
    buttons_list('krios') = struct('label', 'KRIOS', ...
                            'path', '\\dc\dls\science\groups\vibration\monitoring\ebic\krios\',...
                            'description', 'KRIOS hall, inside EM enclosure');

                        
    gui_settings.buttons_list = buttons_list;
end