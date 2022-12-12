function generate_legend(legend_string_array,interpreter_string)
    dim=length(legend_string_array);
    for i =1:dim
        legend_string_array(i)=join(['"',legend_string_array(i),'",'],'');
    end
    total_legend_string=join(legend_string_array);
    command_string=join(["legend(",total_legend_string,"'interpreter','",interpreter_string,"');"]);
    eval(command_string);
end