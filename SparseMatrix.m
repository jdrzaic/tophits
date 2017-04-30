classdef SparseMatrix < handle
    % Sparse matrix format
    
    properties
        n
        m
        mat
    end
    
    methods
        function obj = SparseMatrix(n, m)
           obj.n = n;
           obj.m = m;
           % generated data - needs indexing overloading
           obj.mat = cell(m, 1);
        end
        
        function addCoordinateForWord(obj, wordInd, i, j)
            currSize = length(obj.mat{wordInd});
            obj.mat{wordInd}(currSize + 1) = i;
            obj.mat{wordInd}(currSize + 2) = j;
        end
        
        %function varargout = subsref(obj, S)
        %   if length(S) == 1 && strcmp(S(1).type, '()')
        %       S.sub
        %   end
        %end
    end 
end

