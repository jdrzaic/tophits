classdef TensorOperations < handle
    
    properties
    end
    
    methods(Static)
        function size = size(t, num)
            switch(num)
                case 1
                    size = t.k;
                case 2
                    size = t.l;
                case 3
                    size = t.m;
                otherwise
                    error('Index out of range.')
            end
        end
    end
end